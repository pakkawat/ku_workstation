class SubjectJob < ProgressJob::Base
  #queue_as :default
  def initialize(id,type)
    @subject = Subject.find(id)
    @type = type
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(@subject.ku_users.count)

    if @type == "delete"
      #update all user_subject = false
      @subject.user_subjects.update_all(user_enabled: false)
      #update all programs_subject = false
      @subject.programs_subjects.update_all(program_enabled: false)
      #destroy all UsersPrograms
      UsersProgram.where(:subject_id => @subject.id).destroy_all
    end

    @subject.programs.each do |program|
      File.open("/home/ubuntu/chef-repo/cookbooks/"+program.program_name+"/attributes/user_list.rb", 'w') do |f|
        f.write("default['user_list'] = " + create_user_list(KuUser.where(id: UsersProgram.where(:program_id => program.id).uniq.pluck(:ku_user_id)).pluck(:ku_id)))
      end
      #to_do upload cookbook
    end

    program_enable_true = create_runlist(@subject.programs.where("programs_subjects.program_enabled = true").pluck(:program_name))

    arr_error = Array.new
    arr_error.push("There are error with following user id:")

    @subject.ku_users.each do |user|
      if system "knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb"
        if user.user_subjects.where(:subject_id => @subject.id).pluck(:user_enabled)
          if system "knife node run_list add " + user.ku_id + " '" + program_enable_true.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
            program_enable_false = create_runlist(@subject.programs.where("programs_subjects.program_enabled = false").where.not(:id => UsersProgram.where(:ku_user_id => user.id).uniq.pluck(:program_id)).pluck(:program_name))
            if !(system "knife node run_list remove " + user.ku_id + " '" + program_enable_false.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb")
              arr_error.push(user.ku_id+"(error run_list remove), ")
            end
          else
            arr_error.push(user.ku_id+"(error run_list add), ")
          end
        else # user.user_enabled = false
          # all program that in this subject but not in UsersProgram table because when user_enabled = false will deleted all program_id(program_enabled = true) with subject_id in UserProgram table
          all_programs = create_runlist(@subject.programs.where.not(:id => UsersProgram.where(:ku_user_id => user.id).uniq.pluck(:program_id)).pluck(:program_name))
          if !(system "knife node run_list remove " + user.ku_id + " '" + all_programs.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb")
            arr_error.push(user.ku_id+"(error run_list remove), ")
          end
        end
      else
        arr_error.push(user.ku_id+"(error ssh), ")
      end
      if !(system "knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb")
        arr_error.push(user.ku_id+"(error ssh), ")
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
