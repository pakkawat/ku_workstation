class KuUserJob < ProgressJob::Base
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
    update_progress_max(@type == "create" ? 5 : 2)
    new_password = encryp_password
    #@users.each do |user|
      #Dir.chdir("/home/ubuntu") do
      	#system "ruby long.rb"
      #end
      #update_progress
    #end
    str_temp = ""
    if @type == "create"
      if system "knife ec2 server create -x ubuntu -I ami-96f1c1c4 -f t2.small -G 'Chef Clients' -N " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
        sleep(10)
        update_progress
      else
        raise "Error Create instance"
      end
      if system "knife cookbook create " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
        write_file(new_password)
        update_progress
      else
        raise "Error Create user cookbook"
      end
      if system "knife cookbook upload " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
        update_progress
      else
        raise "Error can not upload user cookbook"
      end
      if system "knife node run_list add " + @user.ku_id + " 'recipe[chef-client],recipe[" + @user.ku_id + "],recipe[base-client]' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        sleep(5)
        update_progress
      else
        raise "Error Add run_list"
      end
      if system "knife ssh 'name:" + @user.ku_id + "' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb"
        update_progress
      else
        raise "Error ssh"
      end
    else #delete user
      require 'chef'
      Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
      query = Chef::Search::Query.new
      node = query.search('node', 'name:' + @user.ku_id).first rescue []
      if system "knife ec2 server delete " + node[0].ec2.instance_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb --purge -y"
        update_progress
      else
        raise "Error delete instance"
      end
      if system "knife cookbook delete " + @user.ku_id + " -c /home/ubuntu/chef-repo/.chef/knife.rb -y"
        FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id)
        update_progress
      else
        raise "Error delete cookbook files"
      end
    end
    #File.open('/home/ubuntu/myapp/public/ku_user_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
    if @type == "delete"
      @user.destroy
    end
  end

  def error(job, exception)
    if @type == "create"
      @user.destroy
    end
    exit
  end

  def encryp_password
    salt = rand(36**8).to_s(36)
    shadow_hash = @password.crypt("$6$" + salt)
    return shadow_hash.to_s
  end

  def write_file(new_password)
    file_path = "/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "recipes/default.rb"
    File.open(file_path, 'a') do |file|
      file.puts "user '" + @user.ku_id + "' do"
      file.puts "  home '/home/" + @user.ku_id + "'"
      file.puts "  shell '/bin/bash'"
      file.puts "  supports :manage_home => true"
      file.puts "  password '" + new_password + "'"
      file.puts "  action :create"
      file.puts "end"
      file.puts ""
      file.puts "execute 'create folder guacamole' do"
      file.puts "  command sudo mkdir /etc/guacamole"
      file.puts "  not_if { ::File.exists?(/etc/guacamole) }"
      file.puts "  action :run"
      file.puts "end"
      file.puts ""
      file.puts "template '/etc/guacamole/noauth-config.xml' do"
      file.puts "  source 'noauth-config.xml.erb'"
      file.puts "  mode '0755'"
      file.puts "end"
      file.puts ""
    end

    file_path = "/home/ubuntu/chef-repo/cookbooks/" + @user.ku_id + "template/noauth-config.xml.erb"
    File.open(file_path, 'w+') do |file|
      file.puts "<configs>"
      file.puts "  <config name=\"RDP - Ubuntu pakk\" protocol=\"rdp\">"
      file.puts "    <param name=\"hostname\" value=\"<%= node['ec2']['public_hostname'] %>\" />"
      file.puts "    <param name=\"port\" value=\"3389\" />"
      file.puts "    <param name=\"username\" value=\"" + @user.ku_id + "\" />"
      file.puts "    <param name=\"password\" value=\"" + new_password + "\" />"
      file.puts "  </config>"
      file.puts "</configs>"
    end
  end

end
