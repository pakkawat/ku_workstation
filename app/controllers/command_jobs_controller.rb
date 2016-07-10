class CommandJobsController < ApplicationController
  def index
  	#@jobs = Delayed::Job.all
  end

  def destroy
  	Delayed::Job.find(params[:job_id]).destroy
  	flash[:success] = "Job deleted"
  	redirect_to dashboard_index_path
  end

  def refresh_part
  	# get whatever data you need to a variable named @data
  	@jobs = Delayed::Job.all.order("id ASC")
  	respond_to do |format|
  		format.js
  	end

  end
end
