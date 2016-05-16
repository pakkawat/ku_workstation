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

    #prepare_user_config ปล่อยให้ user กำหนดค่า config แล้ว apply change กันเอง
    generate_chef_resource

    if @type == "delete"
      delete_all_user
      remove_program_from_users
    else # apply_change
      apply_change
      clear_remove_disuse_resource
      create_user_config_for_each_user
    end
    second_ssh_run
    #File.open('/home/ubuntu/myapp/public/programs_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
    RemoveResource.where(program_id: @program.id).destroy_all
    if @type == "delete"
      if KnifeCommand.run("knife cookbook delete " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb -y", nil)
        chef_attributes = ChefAttribute.where(chef_resource_id: @program.chef_resources.pluck("chef_resource_id")).pluck("id")
        users = UsersProgram.where(:program_id => @program.id).pluck("ku_user_id")
        ChefValue.where(chef_attribute_id: chef_attributes, ku_user_id: users).destroy_all

        #sleep(2)
        FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name)
        @program.destroy
      else
        raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, "
      end
    else #apply_change
      @program.programs_subjects.update_all(:was_updated => false, :state => "none", :applied => true)
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
      f.write("default['#{@program.program_name}']['user_list'] = []")
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
        f.write(ResourceGenerator.resource(chef_resource, @program))
      end
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/uninstall_programs.rb", 'w') do |f|
      @program.chef_resources.each do |chef_resource|
        f.write(ResourceGenerator.uninstall_resource(chef_resource, @program))
      end
    end

    remove_resources = RemoveResource.where(program_id: @program.id)
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
      remove_resources.each do |remove_resource|
        f.write(ResourceGenerator.remove_disuse_resource(remove_resource, @program))
      end
    end

    if !KnifeCommand.run("knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, "
    end

  end

  def prepare_user_config # mark not use
    #chef_attributes = ChefAttribute.where(chef_resource_id: @program.chef_resources.pluck("id"))
    @users.each do |user|
      #chef_attributes.each do |chef_attribute|
        #ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: user).first_or_create
      #end

      File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/attributes/user_config.rb", 'w') do |f|
        f.write(generate_user_config(user))
      end

      if !KnifeCommand.run("knife cookbook upload " + user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, "
      end

    end
  end

  def generate_user_config(user) # mark not use
    str_temp = ""
    config_names = ""
    all_user_programs = Program.where(id: user.users_programs.pluck("program_id"))
    all_user_programs.each do |program|
      chef_attributes = user.chef_attributes.where(chef_resource_id: program.chef_resources.pluck("id"))
      chef_values = user.chef_values.where(chef_attribute_id: chef_attributes)
      chef_values.each do |chef_value|
        chef_attribute = ChefAttribute.find(chef_value.chef_attribute_id)
        config_names += "node['#{chef_attribute.name}'],"
        str_temp += "default['#{chef_attribute.name}'] = '#{chef_value.value}'\n"
      end
      config_names = config_names.gsub(/\,$/, '')
      str_temp += "default['#{program.program_name}']['user_config_list'] = [#{config_names}] \n"
      config_names = ""
    end

    return str_temp
  end

  def create_user_config_for_each_user
    chef_attributes = ChefAttribute.where(chef_resource_id: @program.chef_resources.pluck("id"))
    users = UsersProgram.where(program_id: @program.id).pluck("ku_user_id")
    users.each do |user|
      chef_attributes.each do |chef_attribute|
        ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: user).first_or_create
      end
    end
  end # end def

end
