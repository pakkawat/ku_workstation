class ProgramsSubjectJob < ActiveJob::Base
  #queue_as :default
  def initialize(users)
    @users = users
  end

  def perform
    # Do something later
    update_stage('Run command')
    update_progress_max(@users.count)
    @users.each do |user|
      sleep(5)
      update_progress
    end
  end
  
end
