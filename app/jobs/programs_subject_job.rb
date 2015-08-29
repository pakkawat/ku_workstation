class ProgramsSubjectJob < ProgressJob::Base
  #queue_as :default
  def initialize(subject)
    @subject = subject
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(@subject.ku_users.count)
    #@users.each do |user|
      #sleep(5)
      #update_progress
    #end

    #str_temp = ""
    arr_error = Array.new
    arr_error.push("There are error with following user id:")
    check_error1 = true
    check_error2 = true
    check_error3 = true
    #@subject = Subject.find(params[:subject_id])
    str_remove_program = get_remove_program
    @subject.ku_users.where("user_subjects.user_enabled = true").each do |user|# send run_list to Chef-server and run sudo chef-clients
      if !user.run_list.blank?
        #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        #str_temp += " || " + "\n"
        check_error1 = system "knife node run_list remove " + user.ku_id + " '" + str_remove_program + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        check_error2 = system "knife node run_list add " + user.ku_id + " '" + user.run_list.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        check_error3 = system "knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb"

        if ((check_error1 == false) or (check_error2 == false) or (check_error3 == false))
          str_error = "" + user.ku_id + "(Error:"
          str_error += "remove run_list," if check_error1 == false
          str_error += "add run_list," if check_error2 == false
          str_error += "ssh," if check_error3 == false
          str_error = str_error.gsub(/\,$/, '')
          str_error += ")"
          str_error += ", "
          arr_error.push(str_error)
        end
        update_progress
        check_error1 = true
        check_error2 = true
        check_error3 = true
      end
    end

    if arr_error.length > 1
      str_error = ""
      arr_error.each do |error|
        str_error += error
      end
      raise str_error
    end
    #File.open('/home/ubuntu/myapp/public/programs_subject_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
    @subject.programs.where("programs_subjects.program_enabled = false").each do |program|
      @subject.ku_users.each do |user|
        # delete recipe[remove-xxx], from user.run_list
        user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
      end
    end
    # delete relationship
    @subject.programs_subjects.where(program_enabled: false).destroy_all
  end

  def error(job, exception)
  	#
  end

  def get_remove_program
    str_remove_program = ""
    @subject.programs.where("programs_subjects.program_enabled = false").each do |program|
      str_remove_program += "recipe[" + program.program_name + "],"
    end
    return str_remove_program.gsub(/\,$/, '')
  end

end
