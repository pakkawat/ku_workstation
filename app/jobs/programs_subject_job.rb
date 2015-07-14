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
    #@subject = Subject.find(params[:subject_id])
    @subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
      if !user.run_list.blank?
        str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        str_temp += " || " + "\n"
        update_progress
      end
    end
    File.open('/home/ubuntu/myapp/public/programs_subject_job.txt', 'w') { |f| f.write(str_temp) }
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

  def failure
  	#
  end

end
