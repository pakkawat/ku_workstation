class CommandJob < ProgressJob::Base
  def initialize(users, progress_max)
    super progress_max: progress_max
    @users = users
  end

  def perform
    update_stage('Run command')
    @users.each do |user|
      sleep(3.0)
      update_progress
    end

    #File.open('path/to/export.csv', 'w') { |f| f.write(csv_string) }
  end
end