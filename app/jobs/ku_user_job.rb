class UserSubjectJob < ProgressJob::Base
  #queue_as :default
  def initialize(user,type)
    @user = user
    @type = type
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(1)
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
      end
    else #delete user
      Dir.chdir("/home/ubuntu/chef-repo") do
        system "knife ec2 server delete i-b9153775 --purge -y"+@user.ku_id
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
