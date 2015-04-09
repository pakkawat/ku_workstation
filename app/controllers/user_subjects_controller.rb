class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectusers = @subject.ku_users
    @users = KuUser.where.not(id: @subjectusers)
  end

  def create
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    @subject.user_subjects.create(ku_user: @kuuser)
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    UserSubject.find_by(ku_user_id: @kuuser.id, subject_id: @subject.id).destroy
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end
end
