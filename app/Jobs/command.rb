class CommandJob < ProgressJob::Base
  def initialize(users)
    @users = users
  end

  def perform
    update_stage('Run command')
    update_progress_max(@users.count)
    #@users.each do |user|
      #sleep(3.0)
      #update_progress
    #end
    update_progress

    File.open('/home/ubuntu/myapp/public/export.csv', 'w') { |f| f.write('aaa') }
  end
end