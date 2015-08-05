class SubjectJob < ProgressJob::Base
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
    #@subject.programs.each do |program|
      #@subject.ku_users.each do |user|
        #user.update_column(:run_list, user.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"))
        #if other_user_subject_use_this_program(user,program)
          #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],")
          #str_temp += " || <br>"
        #end
      #end
    #end
    # all_programs that use only in this subject
    #all_programs = @subject.programs.where(id: ProgramsSubject.select("program_id").group("program_id").having("COUNT(subject_id)=1").where(program_enabled: true))
    #run_list_remove = Hash[all_programs.map { |program| ["recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"] }]
    #delete_remove_recipe = Hash[all_programs.map { |program| ["recipe[remove-" + program.program_name + "],", ""] }]
    arr_error = Array.new
    arr_error.push("There are error with following user id:")
    check_error = true

    @subject.ku_users.each do |user|

      programs_in_subject = @subject.programs.where.not(id: ProgramsSubject.select("program_id").where(subject_id: user.user_subjects.select("subject_id").where.not(subject_id: @subject.id).where(user_enabled: true)  ).where(program_enabled: true)  )
      run_list_remove = Hash[programs_in_subject.map { |program| ["recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"] }]
      delete_remove_recipe = Hash[programs_in_subject.map { |program| ["recipe[remove-" + program.program_name + "],", ""] }]

      run_list_remove.each {|k,v| user.update_column(:run_list, user.run_list.gsub(k, v))}
      
      #all_programs.each {|k,v| user.update_column(:run_list, user.run_list.gsub(k, v))}
      str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '') + " || "
      # 1. send run_list to chef-server
      #---
      # 2. update run_list recipe[remove-xxx] to ''

      check_error = system "knife node run_list add " + user.ku_id + " '" + user.run_list.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
      sleep(2)
      check_error = system "knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb"

      if check_error == false
        arr_error.push(user.ku_id+",")
      else
        delete_remove_recipe.each {|k,v| user.update_column(:run_list, user.run_list.gsub(k, v))}
      end

      update_progress
      check_error = true

    end

    if arr_error.length > 1
      str_error = ""
      arr_error.each do |error|
        str_error += error
      end
      raise str_error
    end
    #File.open('/home/ubuntu/myapp/public/subject_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
    @subject.destroy
  end

  def error(job, exception)
  	#
  end

end
