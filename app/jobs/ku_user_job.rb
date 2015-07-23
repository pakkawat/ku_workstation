class KuUserJob < ProgressJob::Base
  #queue_as :default
  require 'chef'
  def initialize(user,type)
    @user = user
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
      Dir.chdir("/home/ubuntu/chef-repo") do
        system "knife ec2 server create -x ubuntu -I ami-96f1c1c4 -f t2.small -G 'Chef Clients' -N "+@user.ku_id
        update_progress
        system "knife node run_list add "+@user.ku_id+" 'recipe[chef-client]'"
        update_progress
        system "knife ssh 'name:"+@user.ku_id+"' 'sudo chef-client' -x ubuntu"
        update_progress
      end
    else #delete user
      node = query.search('node', 'name:'+@user.ku_id).first rescue []
      Dir.chdir("/home/ubuntu/chef-repo") do
        system "knife ec2 server delete "+node.ec2.instance_id+" --purge -y"
        update_progress
      end
    end
    File.open('/home/ubuntu/myapp/public/ku_user_job.txt', 'w') { |f| f.write(str_temp) }
  end

  def success
    if @type == "delete"
      @user.destroy
    end
  end

  def failure
  	#
  end

end
