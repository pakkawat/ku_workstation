class UserSubjectJob < ProgressJob::Base
  #queue_as :default
  def initialize(users)
    @users = users
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(@users.count)
    @users.each do |user|
      Dir.chdir("/home/ubuntu/chef-repo") do
      	system "ruby long.rb"
      end
      update_progress
    end
    
  end

end
