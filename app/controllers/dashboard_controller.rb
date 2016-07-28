class DashboardController < ApplicationController
  def index
    @subjects = Subject.all
    @programs = Program.all
    @jobs = Delayed::Job.all.order("id ASC")
    gon.ku_user_name = current_user.firstname
  end

  def refresh_jobs
    @jobs = Delayed::Job.all.order("id ASC")
  	respond_to do |format|
  		format.js
  	end
  end
end
