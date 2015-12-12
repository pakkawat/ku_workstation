class ProgramJob < ProgressJob::Base
  include KnifeCommand
  #queue_as :default
  def initialize(program)
    @program = program
  end

  def perform
    # Do something later
    update_stage('Run command')
    users = KuUser.where(id: UsersProgram.where(:program_id => @program.id).uniq.pluck(:ku_user_id))
    update_progress_max(users.count)
    #@users.each do |user|
      #sleep(5)
      #update_progress
    #end

    File.open("/home/ubuntu/chef-repo/cookbooks/"+program.program_name+"/attributes/user_list.rb", 'w') do |f|
      f.write("default['user_list'] = []")
    end

    arr_error = Array.new
    arr_error.push("There are error with following user id:")

    #str_temp = ""
    users.each do |user|
      error_length = arr_error.length
      if KnifeCommand.run("knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        if KnifeCommand.run("knife node run_list remove " + user.ku_id + " 'recipe[" + @program.program_name + "]' -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
          # run ssh again for download file if other program use same file in this program
          if !KnifeCommand.run("knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
            arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
          end
        else
          arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
        end
      else
        arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
      end

      update_progress

    end

    if arr_error.length > 1
      str_error = ""
      arr_error.each do |error|
        str_error += error
      end
      raise str_error
    end
    #File.open('/home/ubuntu/myapp/public/programs_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
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

  def error(job, exception)
  	#
  end

end
