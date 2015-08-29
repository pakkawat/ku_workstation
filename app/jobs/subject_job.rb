class SubjectJob < ProgressJob::Base
  #queue_as :default
  def initialize(subject,type)
    @subject = Subject.find(id)
    @type = type
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

    @subject.ku_users.each do |user|
      if !user.run_list.blank?
        remove_programs = ""
        remove_programs2 = ""
        delete_remove_recipe = Hash.new
        check_error1 = true
        check_error2 = true
        check_error3 = true
        if @type == "delete"
          programs_in_subject = @subject.programs.where.not(id: ProgramsSubject.select("program_id").where(subject_id: user.user_subjects.select("subject_id").where.not(subject_id: @subject.id).where(user_enabled: true)  ).where(program_enabled: true)  )
          programs_in_subject.each do |program|
            remove_programs += "recipe[" + program.program_name + "],"
            remove_programs2 += "recipe[remove-" + program.program_name + "],"
            user.update_column(:run_list, user.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"))
            delete_remove_recipe.store("recipe[remove-" + program.program_name + "],", "")
          end
        else # apply change
          remove_programs, remove_programs2, delete_remove_recipe = get_user_remove_program(user)
        end # if @type == "delete"
        ############
        if remove_programs != ""
          check_error1 = system "knife node run_list remove " + user.ku_id + " '" + remove_programs.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        end
        check_error2 = system "knife node run_list add " + user.ku_id + " '" + user.run_list.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        sleep(2)
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
          if remove_programs2 != ""
            #remove_programs = user.run_list.scan(/recipe\[remove\-.*?\]\,/) # output: recipe[remove-aaa],recipe[remove-bbb],
            if system "knife node run_list remove " + user.ku_id + " '" + remove_programs2.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb"
              delete_remove_recipe.each {|k,v| user.update_column(:run_list, user.run_list.gsub(k, v))}
            else
              arr_error.push(user.ku_id + "(Error:remove run_list 2), ")
            end
          end
        end# if ((check_error1 == false) or ...
        ############
      end # if !user.run_list.blank?
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
      #@subject.programs.where("programs_subjects.program_enabled = false").each do |program|
        #@subject.ku_users.each do |user|
          # delete recipe[remove-xxx], from user.run_list
          #user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
        #end
      #end
      # delete relationship
      @subject.programs_subjects.where(program_enabled: false).destroy_all

      #@subject.ku_users.where("user_subjects.user_enabled = false").each do |user|
        #@subject.programs.each do |program|
          # delete recipe[remove-xxx], from user.run_list
          #user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
        #end
      #end
      # delete relationship
      @subject.user_subjects.where(user_enabled: false).destroy_all
    end
  end

  def error(job, exception)
  	#
  end

  def get_user_remove_program(user)
    str_remove_program = ""
    str_remove_program2 = ""
    hash_remove_program = Hash.new
    programs = user.run_list.scan(/recipe\[remove\-.*?\]\,/) # find recipe[remove-xxx]
    programs.each do |program|
      str_remove_program += "recipe[" + program[14..-3] + "],"
      str_remove_program2 += program
      hash_remove_program.store(program, "")
    end
    return str_remove_program, str_remove_program2, hash_remove_program # output1: recipe[aaa],recipe[bbb] output2: recipe[remove-aaa],recipe[remove-bbb]
  end

end
