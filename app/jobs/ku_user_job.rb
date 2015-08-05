class KuUserJob < ProgressJob::Base
  #queue_as :default
  def initialize(id,type)
    @user = KuUser.find(id)
    @type = type
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(@type == "create" ? 3 : 1)
    #@users.each do |user|
      #Dir.chdir("/home/ubuntu") do
      	#system "ruby long.rb"
      #end
      #update_progress
    #end
    str_temp = ""
    if @type == "create"
      if system "knife ec2 server create -x ubuntu -I ami-96f1c1c4 -f t2.small -G 'Chef Clients' -N "+@user.ku_id+" -c /home/ubuntu/chef-repo/.chef/knife.rb"
        sleep(10)
        update_progress
      else
        raise "Error Create instance"
      end
      if system "knife node run_list add "+@user.ku_id+" 'recipe[chef-client]' -c /home/ubuntu/chef-repo/.chef/knife.rb"
        sleep(5)
        update_progress
      else
        raise "Error Add run_list"
      end
      if system "knife ssh 'name:"+@user.ku_id+"' 'sudo chef-client' -x ubuntu -c /home/ubuntu/chef-repo/.chef/knife.rb"
        update_progress
      else
        raise "Error ssh"
      end
    else #delete user
      require 'chef'
      Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
      query = Chef::Search::Query.new
      node = query.search('node', 'name:'+@user.ku_id).first rescue []
      if system "knife ec2 server delete "+node[0].ec2.instance_id+" -c /home/ubuntu/chef-repo/.chef/knife.rb --purge -y"
        update_progress
      else
        raise "Error delete instance"
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
  end

end
