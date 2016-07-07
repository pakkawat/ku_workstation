class DashboardController < ApplicationController
  def index
    @subjects = Subject.all
    @programs = Program.all
    @jobs = Delayed::Job.all
  end
end
