class ProgramJob < ProgressJob::Base
  include KnifeCommand
  #queue_as :default
  def initialize(program, type)
    @program = program
    @type = type
  end

  def perform
    # Do something later
    update_stage('Run command')
    @users = KuUser.where(id: UsersProgram.where(:program_id => @program.id).uniq.pluck(:ku_user_id))
    update_progress_max(@users.count*2)
    #@users.each do |user|
      #sleep(5)
      #update_progress
    #end
    @arr_error = Array.new
    @arr_error.push("There are error with following user id:")

    generate_chef_resource

    if @type == "delete"
      delete_all_user
      remove_program_from_users
    else # apply_change
      apply_change
      clear_remove_disuse_resource
    end
    second_ssh_run
    #File.open('/home/ubuntu/myapp/public/programs_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
    RemoveResource.where(program_id: @program.id).destroy_all
    if @type == "delete"
      if KnifeCommand.run("knife cookbook delete " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb -y", nil)
        #@program.programs_subjects.destroy_all
        #UsersProgram.where(:sprogram_id => @program.id).destroy_all
        #@program.subjects.destroy_all
        #sleep(2)
        FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name)
        @program.destroy
      else
        raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, "
      end
    end
  end

  def error(job, exception) #####  need to test this function if error program will continue on this function ?
    remove_resources = RemoveResource.where(program_id: @program.id)
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
      remove_resources.each do |file|
        f.write(ResourceGenerator.remove_disuse_resource(file))
      end
    end

    if !KnifeCommand.run("knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
    end

    check_error("6. ")
  end

  def delete_all_user
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/attributes/user_list.rb", 'w') do |f|
      f.write("default['user_list'] = []")
    end

    if !KnifeCommand.run("knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
    end

    check_error("1. ")
  end

  def remove_program_from_users
    #str_temp = ""
    @users.each do |user|
      if KnifeCommand.run("knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        if !KnifeCommand.run("knife node run_list remove " + user.ku_id + " 'recipe[" + @program.program_name + "]' -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
          arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
        end
      else
        arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
      end

      update_progress

    end

    check_error("2. ")
  end

  def second_ssh_run
    @users.each do |user|
      ku_id = user.ku_id
      if !KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        @arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
      end

      update_progress
    end

    check_error("3. ")
  end

  def apply_change
    @users.each do |user|
      ku_id = user.ku_id
      if !KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        @arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
      end

      update_progress
    end

    check_error("4. ")
  end

  def clear_remove_disuse_resource
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
      f.write("")
    end
    if !KnifeCommand.run("knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
    end

    check_error("5. ")
  end

  def check_error(test)
    if @arr_error.length > 1
      str_error = ""
      @arr_error.each do |error|
        str_error += error
      end
      raise test + str_error
    end
  end

  def generate_chef_resource
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/install_programs.rb", 'w') do |f|
      @program.chef_resources.each do |chef_resource|
        if chef_resource.resource_type == "Config_file"
          f.write(ResourceGenerator.config_file(chef_resource, @program))
        else
          f.write(ResourceGenerator.resource(chef_resource))
        end
      end
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/uninstall_programs.rb", 'w') do |f|
      @program.chef_resources.each do |chef_resource|
        if chef_resource.resource_type == "Config_file"
          f.write(ResourceGenerator.delete_config_file(chef_resource, @program))
        else
          f.write(ResourceGenerator.uninstall_resource(chef_resource))
        end
      end
    end

    remove_resources = RemoveResource.where(program_id: @program.id)
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
      remove_resources.each do |remove_resource|
        if remove_resource.resource_type == "Config_file"
          f.write(ResourceGenerator.remove_config_file(remove_resource, @program))
        else
          f.write(ResourceGenerator.remove_disuse_resource(remove_resource))
        end
      end
    end

    if !KnifeCommand.run("knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, "
    end

  end



end
