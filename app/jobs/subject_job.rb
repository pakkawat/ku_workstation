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
    update_progress_max(@subject.ku_users.count*2) # each user run ssh two times
    @arr_error = Array.new
    if @type == "delete"
      #update all user_subject = false
      @subject.user_subjects.update_all(user_enabled: false)
      #update all programs_subject = false
      @subject.programs_subjects.update_all(program_enabled: false)
    end

    @arr_error.push(" There are error with following: ")

    prepare_user_list

    first_ssh_run

    second_ssh_run

  end

  def success
    if @type == "delete"
      #destroy all UsersPrograms
      UsersProgram.where(:subject_id => @subject.id).destroy_all
      @subject.destroy
    else # apply change

      # delete relationship
      # future job
      #chef_attributes_with_program_false = ChefAttribute.where(chef_resource_id: ProgramChef.where(program_id: @subject.programs_subjects.where(program_enabled: false).pluck("program_id")).pluck("chef_resource_id")).pluck("id")
      #users_with_false = @subject.user_subjects.where(user_enabled: false).pluck("ku_user_id")
      #ChefValue.where(chef_attribute_id: chef_attributes_with_program_false, ku_user_id: users_with_false).destroy_all
      ###################################################
      UsersProgram.where(subject_id: @subject.id, program_id: @subject.programs_subjects.where(program_enabled: false).pluck("program_id")).destroy_all

      @subject.programs_subjects.where(program_enabled: false).destroy_all

      @subject.user_subjects.where(user_enabled: false).destroy_all
    end
  end

  def error(job, exception)
    #output = File.open("/home/ubuntu/subject_error.txt","w")
    #output << ""
    #output.close
  end

  def prepare_user_list
    @subject.programs.each do |program|
      File.open("/home/ubuntu/chef-repo/cookbooks/"+program.program_name+"/attributes/user_list.rb", 'w') do |f|
        f.write("default['#{program.program_name}']['user_list'] = " + create_user_list(KuUser.where(id: UsersProgram.where(:program_id => program.id).uniq.pluck(:ku_user_id)).pluck(:ku_id)))
      end

      if !KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
      end

      #prepare_user_config(program)
    end

    #create_user_config

    check_error("1. ")

  end

  #def prepare_user_config(program)
    #chef_attributes = ChefAttribute.where(chef_resource_id: program.chef_resources.pluck("id"))
    #@subject.ku_users.where("user_subjects.user_enabled = true").each do |user|
      #chef_attributes.each do |chef_attribute|
        #ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: user).first_or_create
      #end
    #end
  #end

  #def create_user_config
    #@subject.ku_users.where("user_subjects.user_enabled = true").each do |user|
      #File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/attributes/user_config.rb", 'w') do |f|
        #f.write(generate_user_config(user))
      #end

      #if !KnifeCommand.run("knife cookbook upload " + user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        #@arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
      #end
    #end
  #end

  def generate_user_config(user)
    str_temp = ""
    config_names = ""
    all_user_programs = Program.where(id: user.users_programs.pluck("program_id"))
    all_user_programs.each do |program|
      chef_attributes = user.chef_attributes.where(chef_resource_id: program.chef_resources.pluck("id"))
      chef_values = user.chef_values.where(chef_attribute_id: chef_attributes)
      chef_values.each do |chef_value|
        chef_attribute = ChefAttribute.find(chef_value.chef_attribute_id)
        config_names += "node['#{chef_attribute.name}'],"
        str_temp += "default['#{chef_attribute.name}'] = '#{chef_value.value}'\n"
      end
      config_names = config_names.gsub(/\,$/, '')
      str_temp += "default['#{program.program_name}']['user_config_list'] = [#{config_names}] \n"
      config_names = ""
    end

    return str_temp
  end


  def first_ssh_run
    program_enable_true = create_run_list(@subject.programs.where("programs_subjects.program_enabled = true").pluck(:program_name))

    @subject.ku_users.each do |user|
      ku_id = user.ku_id
      if KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        if user.user_subjects.where(:subject_id => @subject.id).pluck(:user_enabled).first
          if KnifeCommand.run("knife node run_list add " + ku_id + " '" + program_enable_true.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
            program_enable_false = create_run_list(@subject.programs.where("programs_subjects.program_enabled = false").where.not(:id => UsersProgram.where(:ku_user_id => user.id).uniq.pluck(:program_id)).pluck(:program_name))
            if !KnifeCommand.run("knife node run_list remove " + ku_id + " '" + program_enable_false.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
              @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
            end
          else
            @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
          end
        else # user.user_enabled = false
          # all program that in this subject but not in UsersProgram table because when user_enabled = false will deleted all program_id(program_enabled = true) with subject_id in UserProgram table
          all_programs = create_run_list(@subject.programs.where.not(:id => UsersProgram.where(:ku_user_id => user.id).uniq.pluck(:program_id)).pluck(:program_name))
          if !KnifeCommand.run("knife node run_list remove " + ku_id + " '" + all_programs.gsub(/\,$/, '') + "' -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
            @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
          end
        end
      else
        @arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
      end

      update_progress
    end#@subject.ku_users.each do |user|

    check_error("2. ")

  end

  def second_ssh_run

    @subject.ku_users.each do |user|
      ku_id = user.ku_id
      if !KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        @arr_error.push("#{ActionController::Base.helpers.link_to ku_id, '/logs/'+user.log.id.to_s}, ")
      end

      update_progress
    end

    check_error("3. ")

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

  def check_error(test)
    if @arr_error.length > 1
      str_error = ""
      @arr_error.each do |error|
        str_error += error
      end
      raise test + str_error
    end
  end

end
