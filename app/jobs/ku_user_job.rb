class KuUserJob < ProgressJob::Base
  include KnifeCommand
  require 'digest/sha2'
  #queue_as :default
  def initialize(id,type,password)
    @user = KuUser.find(id)
    @type = type
    @password = password
  end

  def perform
    # Do something later
    update_stage('Run command')
    if @type == "create"
      create_user_and_instance
    elsif @type == "delete"
      delete_user_and_instance
    elsif @type == "destroy_personal_program"
      destroy_personal_program
    else # apply_change
      KnifeCommand.create_empty_log(KuUser.where(id: @user.id))
      user_apply_change
    end

  end

  def success
    if @type == "delete"
      FileUtils.rm("#{Rails.root}/log/knife/#{@user.ku_id}.log")
      #to_do delete logrotate( g0001.log.2) ???
      @user.destroy
    elsif @type == "apply_change"
      @user.personal_programs.where("user_personal_programs.status = 'uninstall'").each do |personal_program|
        File.delete("/home/ubuntu/chef-repo/cookbooks/#{@user.ku_id}/recipes/#{personal_program.program_name}.rb") if File.exist?("/home/ubuntu/chef-repo/cookbooks/#{@user.ku_id}/recipes/#{personal_program.program_name}.rb")
      end
      @user.user_personal_programs.where(status: 'uninstall').destroy_all
      @user.user_personal_programs.update_all(:installed => true,:was_updated => false, :state => "none")
      @user.user_remove_resources.destroy_all
    elsif @type == "create"
      if !KnifeCommand.run("knife node run_list remove " + @user.ku_id + " 'recipe[base-client]' -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'} "
      end
    elsif @type == "destroy_personal_program"
      @personal_program.destroy
    end
  end

  def error(job, exception)
    if @type == "create"
      delete_instance
      @user.destroy
    end
  end

  def create_user_and_instance
    update_progress_max(5)
    new_password = encryp_password

    if KnifeCommand.run("knife ec2 server create -x ubuntu -I ami-96f1c1c4 -f t2.small -G 'Chef Clients' -N " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      sleep(10)
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
    if KnifeCommand.run("knife cookbook create " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb",nil)
      write_file(new_password)
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
    if KnifeCommand.run("knife cookbook upload " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
    if KnifeCommand.run("knife node run_list add " + @user.ku_id + " 'recipe[chef-client],recipe[" + @user.ku_id + "],recipe[base-client]' -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      sleep(5)
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
    if KnifeCommand.run("knife ssh 'name:" + @user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end

  end

  def delete_user_and_instance
    update_progress_max(2)
    require 'chef'
    Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
    query = Chef::Search::Query.new
    node = query.search('node', 'name:' + @user.ku_id).first rescue []
    if KnifeCommand.run("knife ec2 server delete " + node[0].ec2.instance_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb --purge -y", nil)
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
    if KnifeCommand.run("knife cookbook delete " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb -y", nil)
      FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id)
      #FileUtils.rm("/home/ubuntu/myapp/log/knife/" + @user.ku_id + ".log")
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
  end

  def delete_instance
    require 'chef'
    Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
    query = Chef::Search::Query.new
    node = query.search('node', 'name:' + @user.ku_id).first rescue []
    if !KnifeCommand.run("knife ec2 server delete " + node[0].ec2.instance_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb --purge -y", nil)
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
    if KnifeCommand.run("knife cookbook delete " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb -y", nil)
      FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id)
      FileUtils.rm("/home/ubuntu/myapp/log/knife/" + @user.ku_id + ".log")
    else
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
    end
  end

  def user_apply_change
    update_progress_max(3)

    @user.user_error.destroy if !@user.user_error.nil?
    create_chef_value_for_user
    prepare_user_config
    update_progress

    generate_chef_resource_for_personal_program(@user)
    update_progress

    if !KnifeCommand.run("knife cookbook upload " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      raise "#{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}, "
    end

    if KnifeCommand.run("knife ssh 'name:" + @user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", @user)
      update_progress
    else
      raise "#{ActionController::Base.helpers.link_to @user.ku_id, '/ku_users/'+@user.id.to_s}, "
    end
  end

  def encryp_password
    salt = rand(36**8).to_s(36)
    shadow_hash = @password.crypt("$6$" + salt)
    return shadow_hash.to_s
  end

  def write_file(new_password)
    file_path = "/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "/recipes/default.rb"
    File.open(file_path, 'a') do |file|
      file.puts "user '" + @user.ku_id + "' do"
      file.puts "  home '/home/user'"
      file.puts "  shell '/bin/bash'"
      file.puts "  supports :manage_home => true"
      file.puts "  password '" + new_password + "'"
      file.puts "  action :create"
      file.puts "end"
      file.puts ""
      file.puts "execute 'create folder guacamole' do"
      file.puts "  command \"sudo mkdir /etc/guacamole\""
      file.puts "  not_if { ::File.exists?(\"/etc/guacamole\") }"
      file.puts "  action :run"
      file.puts "end"
      file.puts ""
      file.puts "template '/etc/guacamole/noauth-config.xml' do"
      file.puts "  source 'noauth-config.xml.erb'"
      file.puts "  mode '0755'"
      file.puts "end"
      file.puts ""
      file.puts "include_recipe '#{@user.ku_id}::user_remove_disuse_resources'"
      file.puts "include_recipe '#{@user.ku_id}::user_personal_program_list'"
    end

    file_path = "/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "/templates/noauth-config.xml.erb"
    File.open(file_path, 'w+') do |file|
      file.puts "<configs>"
      file.puts "  <config name=\"RDP - Ubuntu " + @user.ku_id + "\" protocol=\"rdp\">"
      file.puts "    <param name=\"hostname\" value=\"<%= node['ec2']['public_hostname'] %>\" />"
      file.puts "    <param name=\"port\" value=\"3389\" />"
      #file.puts "    <param name=\"username\" value=\"" + @user.ku_id + "\" />"
      #file.puts "    <param name=\"password\" value=\"" + @password + "\" />"
      file.puts "  </config>"
      file.puts "</configs>"
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "/attributes/default.rb", 'w') do |f|
      f.write("\n")
      f.write("include_attribute \'#{@user.ku_id}::user_config\'")
      f.write("\n\n")
    end

    output = File.open("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "/attributes/user_config.rb","w")
    output << ""
    output.close

    output = File.open("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "/recipes/user_remove_disuse_resources.rb","w")
    output << ""
    output.close

    output = File.open("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "/recipes/user_personal_program_list.rb","w")
    output << ""
    output.close
  end

  def prepare_user_config
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "/attributes/user_config.rb", 'w') do |f|
      f.write(generate_user_config)
    end
  end

  def generate_user_config
    str_temp = ""
    config_names = ""
    all_user_programs = Program.where(id: @user.users_programs.pluck("program_id"))
    all_user_programs.each do |program|
      chef_attributes = @user.chef_attributes.where(chef_resource_id: program.chef_resources.pluck("id"))
      chef_values = @user.chef_values.where(chef_attribute_id: chef_attributes)
      chef_values.each do |chef_value|
        chef_attribute = ChefAttribute.find(chef_value.chef_attribute_id)
        config_names += "node['#{chef_attribute.name}'],"
        str_temp += "default['#{chef_attribute.name}'] = '#{chef_value.value}'\n"
      end
      config_names = config_names.gsub(/\,$/, '')
      str_temp += "default['#{program.program_name}']['user_config_list'] = [#{config_names}] \n"
      config_names = ""
    end

    config_names = ""
    @user.personal_programs.where("user_personal_programs.status = 'install'").each do |program|
      chef_attributes = @user.chef_attributes.where(personal_chef_resource_id: program.personal_chef_resources.pluck("id"))
      chef_values = @user.chef_values.where(chef_attribute_id: chef_attributes)
      chef_values.each do |chef_value|
        chef_attribute = ChefAttribute.find(chef_value.chef_attribute_id)
        config_names += "node['#{chef_attribute.name}'],"
        str_temp += "default['#{chef_attribute.name}'] = '#{chef_value.value}'\n"
      end
      config_names = config_names.gsub(/\,$/, '')
      str_temp += "default['#{program.program_name}']['user_personal_program_config_list'] = [#{config_names}] \n"
      config_names = ""
    end

    return str_temp
  end

  def generate_chef_resource_for_personal_program(user)
    personal_programs = user.personal_programs
    File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/recipes/user_personal_program_list.rb", 'w') do |f|
      personal_programs.each do |personal_program|
        if user.user_personal_programs.find_by(personal_program_id: personal_program.id).status == "install"
          f.write("if CheckUserPersonalProgramConfig.user_config_#{personal_program.id}(node['#{personal_program.program_name}']['user_personal_program_config_list'])\n")
          f.write("  include_recipe '#{user.ku_id}::#{personal_program.program_name}'\n")
          f.write("end\n")
        else
          f.write("include_recipe '#{user.ku_id}::#{personal_program.program_name}'\n")
        end
      end
    end

    user.personal_programs.where("user_personal_programs.status = 'install'").each do |personal_program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/recipes/#{personal_program.program_name}.rb", 'w') do |f|
        personal_program.personal_chef_resources.where(status: "install").each do |personal_chef_resource|
          f.write(UserResourceGenerator.install_resource(personal_chef_resource, user))
        end
      end
    end

    user.personal_programs.where("user_personal_programs.status = 'uninstall'").each do |personal_program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/recipes/#{personal_program.program_name}.rb", 'w') do |f|
        personal_program.personal_chef_resources.where(resource_type: "Source", status: "install").each do |personal_chef_resource|
          f.write(UserResourceGenerator.uninstall_resource(personal_chef_resource, user))
        end

        personal_program.personal_chef_resources.where(status: "install").where.not(resource_type: "Source").each do |personal_chef_resource|
          f.write(UserResourceGenerator.uninstall_resource(personal_chef_resource, user))
        end
      end
      delete_user_config(user, personal_program)
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/recipes/user_remove_disuse_resources.rb", 'w') do |f|
      user.personal_chef_resources.where("personal_chef_resources.resource_type = 'Source'").each do |remove_resource|
        f.write(UserResourceGenerator.remove_disuse_resource(remove_resource, user))
      end

      user.personal_chef_resources.where.not("personal_chef_resources.resource_type = 'Source'").each do |remove_resource|
        f.write(UserResourceGenerator.remove_disuse_resource(remove_resource, user))
      end
    end

    check_personal_program_config(user, personal_programs)

  end

  def destroy_personal_program
    @personal_program = PersonalProgram.find(@password)
    UserPersonalProgram.where(:personal_program_id => @personal_program.id, :ku_user_id => @personal_program.ku_users).update_all(:status => "uninstall")
    users = @personal_program.ku_users
    update_progress_max(users.count)
    KnifeCommand.create_empty_log(users)
    arr_error = Array.new

    users.each do |user|
      user.user_error.destroy if !user.user_error.nil?
      #generate_chef_resource_for_personal_program(user)
      only_delete_this_personal_program_from_users(user, personal_program)
      delete_user_config(user, personal_program)

      if !KnifeCommand.run("knife cookbook upload " + user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        arr_error.push("System error please contact admin, ")
      end

      if !KnifeCommand.run("knife ssh 'name:" + user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb", user)
        arr_error.push("#{ActionController::Base.helpers.link_to user.ku_id, '/ku_users/'+user.id.to_s}, ")
      end
      update_progress
    end

    if arr_error.length > 0
      str_error = ""
      arr_error.each do |error|
        str_error += error
      end
      raise str_error
    end
  end

  def only_delete_this_personal_program_from_users(user, personal_program)
    File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/recipes/user_personal_program_list.rb", 'w') do |f|
      f.write("include_recipe '#{user.ku_id}::#{personal_program.program_name}'\n")
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/recipes/#{personal_program.program_name}.rb", 'w') do |f|
      personal_program.personal_chef_resources.where(resource_type: "Source", status: "install").each do |personal_chef_resource|
        f.write(UserResourceGenerator.uninstall_resource(personal_chef_resource, user))
      end

      personal_program.personal_chef_resources.where(status: "install").where.not(resource_type: "Source").each do |personal_chef_resource|
        f.write(UserResourceGenerator.uninstall_resource(personal_chef_resource, user))
      end
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/recipes/user_remove_disuse_resources.rb", 'w') do |f|
      user.personal_chef_resources.where("personal_chef_resources.resource_type = 'Source' AND user_remove_resources.personal_program_id = #{personal_program.id}").each do |remove_resource|
        f.write(UserResourceGenerator.remove_disuse_resource(remove_resource, user))
      end

      user.personal_chef_resources.where.not("personal_chef_resources.resource_type = 'Source' AND user_remove_resources.personal_program_id = #{personal_program.id}").each do |remove_resource|
        f.write(UserResourceGenerator.remove_disuse_resource(remove_resource, user))
      end
    end

  end

  def check_personal_program_config(user, personal_programs)
    personal_programs.each do |program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/libraries/check_user_personal_program_config.rb", 'w') do |f|
        if ChefAttribute.where(personal_chef_resource_id: program.personal_chef_resources.pluck("id")).count != 0
          f.write(create_function_to_check_user_config(true, program.id))
        else
          f.write(create_function_to_check_user_config(false, program.id))
        end
      end
    end
  end

  def create_function_to_check_user_config(has_config, program_id)
    str_temp = ""
    str_temp += "module CheckUserPersonalProgramConfig\n"
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

  def create_chef_value_for_user
    @user.personal_programs.each do |program|
      chef_attributes = ChefAttribute.where(personal_chef_resource_id: program.personal_chef_resources.pluck("id"))
      chef_attributes.each do |chef_attribute|
        program.ku_users.each do |user|
          ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: user).first_or_create
        end
      end
    end
  end

  def delete_user_config(user, program)
    chef_attributes = ChefAttribute.where(personal_chef_resource_id: program.personal_chef_resources.pluck("id"))
    user.chef_values.where(chef_attribute_id: chef_attributes).destroy_all
  end

  #def max_attempts
    #3
  #end

end
