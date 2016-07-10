class DashboardController < ApplicationController
  def index
    @subjects = Subject.all
    @programs = Program.all
    @jobs = Delayed::Job.all
  end

  def refresh_jobs
    @jobs = Delayed::Job.all
    respond_to do |format|
        format.js
    end
  end
end
