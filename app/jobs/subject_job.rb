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
    @users = @subject.ku_users
    #update_progress_max(@subject.ku_users.count*2) # each user run ssh two times
    @arr_error = Array.new
    if @type == "delete"
      update_progress_max(@users.count*2)
      delete_user_program_and_user_config
      #update all user_subject = false
      @subject.user_subjects.update_all(user_enabled: false)
      #update all programs_subject = false
      @subject.programs_subjects.update_all(program_enabled: false)
    else # apply_change
      updated_programs = @subject.programs.where("programs_subjects.state != 'none'")
      if updated_programs.count != 0
        update_progress_max(@users.count*2)
        generate_chef_resource(updated_programs)
        check_program_config(updated_programs)
      else
        @users = @subject.ku_users.where("user_subjects.state != 'none'")
        update_progress_max(@users.count*2)
      end
      calculate_user_program_and_user_config
    end

    KnifeCommand.create_empty_log(@users)
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

      RemoveResource.where(program: @subject.programs).destroy_all

      @subject.programs_subjects.update_all(:was_updated => false, :state => "none", :applied => true)
      @subject.user_subjects.update_all(:state => "none", :applied => true)

      clear_remove_disuse_resource
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

  def generate_user_config(user) # mark not use
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

    @users.each do |user|
      ku_id = user.ku_id
      if KnifeCommand.run("knife ssh 'name:" + ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        if user.user_subjects.where(:subject_id => @subject.id).pluck(:user_enabled).first
          program_enable_true = create_run_list(@subject.programs.where("programs_subjects.program_enabled = true").pluck(:program_name))
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
          # Program ทั้งหมดที่อยู่ใน Subject นี้และไม่ใช่ Program ที่ยังอยู่ในตาราง UsersProgram ( ของ User ที่ถูกถอดออกจาก Subject นี้ )
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

    @users.each do |user|
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

  def calculate_user_program_and_user_config

    @users.where("user_subjects.user_enabled = true").each do |user|
      @subject.programs.where("programs_subjects.program_enabled = true").each do |program|
        if !user.users_programs.find_by(:program_id => program.id, :subject_id => @subject.id).present?
          user.users_programs.create(:program_id => program.id, :subject_id => @subject.id)
        end
        add_user_config(user, program)
      end
      @subject.programs.where("programs_subjects.program_enabled = false").each do |program|
        if user.users_programs.where(:program_id => program.id).count == 1
          delete_user_config(user, program)
        end
        user.users_programs.where(:program_id => program.id, :subject_id => @subject.id).destroy_all
      end
    end

    @users.where("user_subjects.user_enabled = false").each do |user|
      @subject.programs.each do |program|
        if user.users_programs.where(:program_id => program.id).count == 1
          delete_user_config(user, program)
        end
        user.users_programs.where(:program_id => program.id, :subject_id => @subject.id).destroy_all
      end
    end

  end

  def add_user_config(user, program)
    chef_attributes = ChefAttribute.where(chef_resource_id: program.chef_resources.pluck("id"))
    chef_attributes.each do |chef_attribute|
      ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: user).first_or_create
    end
  end

  def delete_user_config(user, program)
    chef_attributes = ChefAttribute.where(chef_resource_id: program.chef_resources.pluck("id"))
    user.chef_values.where(chef_attribute_id: chef_attributes).destroy_all
  end

  def delete_user_program_and_user_config
    @subject.ku_users.each do |user|
      @subject.programs.each do |program|
        if user.users_programs.where(:program_id => program.id).count == 1
          delete_user_config(user, program)
        end
        user.users_programs.where(:program_id => program.id, :subject_id => @subject.id).destroy
      end
    end
  end

  def generate_chef_resource(programs)
    programs.each do |program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/recipes/install_programs.rb", 'w') do |f|
        program.chef_resources.each do |chef_resource|
          f.write(ResourceGenerator.resource(chef_resource, program))
        end
      end

      File.open("/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/recipes/uninstall_programs.rb", 'w') do |f|
        program.chef_resources.where("chef_resource.resource_type = 'Source'").each do |chef_resource|
          f.write(ResourceGenerator.uninstall_resource(chef_resource, program))
        end

        program.chef_resources.where("chef_resource.resource_type != 'Source'").each do |chef_resource|
          f.write(ResourceGenerator.uninstall_resource(chef_resource, program))
        end
      end

      remove_resources = RemoveResource.where(program_id: program.id)
      File.open("/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
        remove_resources.where("remove_resource.resource_type = 'Source'").each do |remove_resource|
          f.write(ResourceGenerator.remove_disuse_resource(remove_resource, program))
        end

        remove_resources.where("remove_resource.resource_type != 'Source'").each do |remove_resource|
          f.write(ResourceGenerator.remove_disuse_resource(remove_resource, program))
        end
      end

      #if !KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        #raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, "
      #end
    end # programs.each do |program|
  end # def

  def check_program_config(programs)
    programs.each do |program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/libraries/check_user_config.rb", 'w') do |f|
        if ChefAttribute.where(chef_resource_id: program.chef_resources.pluck("id")).count != 0
          f.write(create_function_to_check_user_config(true, program.id))
        else
          f.write(create_function_to_check_user_config(false, program.id))
        end
      end
    end
  end

  def create_function_to_check_user_config(has_config, program_id)
    str_temp = ""
    str_temp += "module CheckUserConfig\n"
    str_temp += "  def self.user_config_#{program_id}(user_config_list)\n"
    if has_config
      str_temp += "    if !user_config_list.nil?\n"
      str_temp += "      if !user_config_list.empty?\n"
      str_temp += "        user_config_list.each do |config|\n"
      str_temp += "          if config == ''\n"
      str_temp += "            return false\n"
      str_temp += "          end\n"
      str_temp += "        end\n"
      str_temp += "      else\n"
      str_temp += "        return false\n"
      str_temp += "      end\n"
      str_temp += "    else\n"
      str_temp += "      return false\n"
      str_temp += "    end\n"
      str_temp += "    return true\n"
    else
      str_temp += "    return true\n"
    end
    str_temp += "  end\n"
    str_temp += "end\n"
    return str_temp
  end

  def clear_remove_disuse_resource
    @subject.programs.each do |program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
        f.write("")
      end
      if !KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        @arr_error.push("#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, ")
      end
    end

    check_error("5. ")
  end

end
