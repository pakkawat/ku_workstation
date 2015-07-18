class CommandJobsController < ApplicationController
  def index
  	#@jobs = Delayed::Job.all
  end

  def destroy
  	@job.find(params[:id]).destroy
  	flash[:success] = "Job deleted"
  	redirect_to command_jobs_path
  end

  def refresh_part
  	# get whatever data you need to a variable named @data
  	@jobs = Delayed::Job.all.order("id ASC")
  	respond_to do |format|
  		format.js
  	end

  end
end
