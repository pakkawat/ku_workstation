class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:id])  
  end
end
