class UserSubjectJob < ProgressJob::Base
  #queue_as :default
  def initialize(subject)
    @subject = subject
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(@subject.ku_users.count)
    #@users.each do |user|
      #Dir.chdir("/home/ubuntu") do
      	#system "ruby long.rb"
      #end
      #update_progress
    #end

    str_temp = ""
    @subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
      if !user.run_list.blank?
        str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        str_temp += " || " + "\n"

        system "knife node run_list add " + user.ku_id + " '" + user.run_list.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        sleep(2)
        system "knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb"
        
        update_progress
      end
    end
    File.open('/home/ubuntu/myapp/public/user_subject_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
    @subject.ku_users.where("user_subjects.user_enabled = false").each do |user|
      @subject.programs.each do |program|
        # delete recipe[remove-xxx], from user.run_list
        user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
      end
    end
    # delete relationship
    @subject.user_subjects.where(user_enabled: false).destroy_all
  end

  def failure
  	#
  end

end
