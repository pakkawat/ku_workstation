class CommandJobsController < ApplicationController
  def index
  	#@jobs = Delayed::Job.all
  end

  def refresh_part
  	# get whatever data you need to a variable named @data
  	@jobs = Delayed::Job.all
  	respond_to do |format|
  		format.js
  	end

  end
end
