class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectusers = @subject.ku_users
    @users = KuUser.where.not(id: @subjectusers)
  end
end
