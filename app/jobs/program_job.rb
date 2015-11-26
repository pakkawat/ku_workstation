class ProgramJob < ProgressJob::Base
  include KnifeCommand
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
      check_error, error_msg = KnifeCommand.run("knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb")
      if check_error
        check_error, error_msg = KnifeCommand.run("knife node run_list remove " + user.ku_id + " 'recipe[" + @program.program_name + "]' -c /home/ubuntu/chef-repo/.chef/knife.rb")
        if check_error
          user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", ""))
        else
          str_error = "" + user.ku_id + "(Error: "+ error_msg + "),"
          arr_error.push(str_error)
        end
      else
        str_error = "" + user.ku_id + "(Error: "+ error_msg + "),"
        arr_error.push(str_error)
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
      # to_do # knife cookbook delete remove-xxx
      # to_do # rm -rf /home/ubuntu/chef-repo/cookbooks/remove-xxx
    else
      raise "Error delete cookbook:" + @program.program_name
    end
  end

  def error(job, exception)
  	#
  end

end
