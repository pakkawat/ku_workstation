class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:id])  
    @subjectusers = @subject.ku_users
    @users = KuUser.Subject.where.not(subject_id: @subject)
  end
end
