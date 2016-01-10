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
    arr_error = Array.new
    arr_error.push("There are error with following user id:")

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

  def error(job, exception)
  	#
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
    RemoveFile.where(program_id: @program.id).destroy_all
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

end
