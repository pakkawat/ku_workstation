class ProgramJob < ProgressJob::Base
  #queue_as :default
  def initialize(program)
    @program = program
  end

  def perform
    # Do something later
    update_stage('Run command')
    users = KuUser.where(id: UserSubject.select("ku_user_id").where(subject_id: @program.subjects))
    update_progress_max(users.count)
    #@users.each do |user|
      #sleep(5)
      #update_progress
    #end
    arr_error = Array.new
    arr_error.push("There are error with following user id:")

    #str_temp = ""
    users.each do |user|
      check_error1 = true
      check_error2 = true
      check_error3 = true
      check_error1 = system "knife node run_list remove " + user.ku_id + " 'recipe[" + @program.program_name + "]' -c /home/ubuntu/chef-repo/.chef/knife.rb"
      user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", "recipe[remove-" + @program.program_name + "],"))
      sleep(2)
      #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '') +" || " # send run_list to Chef-server and run sudo chef-clients

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
      else
        if system "knife node run_list remove " + user.ku_id + " 'recipe[remove-" + @program.program_name + "]' -c /home/ubuntu/chef-repo/.chef/knife.rb"
          user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + @program.program_name + "],", ""))
        else
          arr_error.push(user.ku_id + "(Error:remove run_list 2), ")
        end
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
    if system "knife cookbook delete " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb -y"
      @program.subjects.destroy_all
      sleep(2)
      FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name)
      @program.destroy
    else
      raise "Error delete cookbook:" + @program.program_name
    end
  end

  def error(job, exception)
  	#
  end

end
