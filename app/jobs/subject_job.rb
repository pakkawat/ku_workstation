class SubjectJob < ProgressJob::Base
  #queue_as :default
  include KnifeCommand
  def initialize(id,type)
    @subject = Subject.find(id)
    @type = type
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(@subject.ku_users.count)
    arr_error = Array.new
    if @type == "delete"
      #update all user_subject = false
      @subject.user_subjects.update_all(user_enabled: false)
      #update all programs_subject = false
      @subject.programs_subjects.update_all(program_enabled: false)
      #destroy all UsersPrograms
      UsersProgram.where(:subject_id => @subject.id).destroy_all
    end

    arr_error.push(" There are error with following: ")

    @subject.programs.each do |program|
      File.open("/home/ubuntu/chef-repo/cookbooks/"+program.program_name+"/attributes/user_list.rb", 'w') do |f|
        f.write("default['user_list'] = " + create_user_list(KuUser.where(id: UsersProgram.where(:program_id => program.id).uniq.pluck(:ku_user_id)).pluck(:ku_id)))
      end
      if !KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
      end
    end

    program_enable_true = create_run_list(@subject.programs.where("programs_subjects.program_enabled = true").pluck(:program_name))

    @subject.ku_users.each do |user|
      ku_id = user.ku_id
      if KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        if user.user_subjects.where(:subject_id => @subject.id).pluck(:user_enabled)
          if KnifeCommand.run("knife node run_list add " + ku_id + " '" + program_enable_true.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
            program_enable_false = create_run_list(@subject.programs.where("programs_subjects.program_enabled = false").where.not(:id => UsersProgram.where(:ku_user_id => user.id).uniq.pluck(:program_id)).pluck(:program_name))
            if KnifeCommand.run("knife node run_list remove " + ku_id + " '" + program_enable_false.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
              if !KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
                arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
              end
            else
              arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
            end
          else
            arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
          end
        else # user.user_enabled = false
          # all program that in this subject but not in UsersProgram table because when user_enabled = false will deleted all program_id(program_enabled = true) with subject_id in UserProgram table
          all_programs = create_run_list(@subject.programs.where.not(:id => UsersProgram.where(:ku_user_id => user.id).uniq.pluck(:program_id)).pluck(:program_name))
          if KnifeCommand.run("knife node run_list remove " + ku_id + " '" + all_programs.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
            if !KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
              arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
            end
          else
            arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
          end
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
  end

  def success
    if @type == "delete"
      @subject.destroy
    else # apply change
      # delete relationship
      @subject.programs_subjects.where(program_enabled: false).destroy_all

      @subject.user_subjects.where(user_enabled: false).destroy_all
    end
  end

  def error(job, exception)
  	#
  end

  def create_run_list(program_list)
    str_temp = ""
    program_list.each do |program|
      str_temp += "recipe[" + program + "],"
    end
    return str_temp
  end

  def create_user_list(user_list)
    str_temp = "["
    user_list.each do |user|
      str_temp += " \"" + user + "\","
    end
    str_temp = str_temp.gsub(/\,$/, '') + " ]"
    return str_temp
  end

end
