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

    str_temp = ""
    arr_error = Array.new
    arr_error.push("There are error with following user id:")
    check_error = true
    #@subject = Subject.find(params[:subject_id])
    @subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
      if !user.run_list.blank?
        str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        str_temp += " || " + "\n"

        check_error = system "knife node run_list add " + user.ku_id + " '" + user.run_list.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        sleep(2)
        check_error = system "knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb"

        if check_error == false
          arr_error.push(user.ku_id+",")
        end
        update_progress
        check_error = true
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

end
