class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectusers = @subject.ku_users.paginate(page: params[:subjectuser_page], per_page: 2).order("ku_id DESC")
    @kuusers = KuUser.where.not(id: @subject.ku_users).paginate(page: params[:kuuser_page], per_page: 2).order("ku_id DESC")
  end

  def create
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    @subject.user_subjects.create(ku_user: @kuuser)
    apply_programs_to_user
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    UserSubject.find_by(ku_user_id: @kuuser.id, subject_id: @subject.id).destroy
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  private
    def apply_programs_to_user
      str_temp = "ku_id: " + @kuuser.ku_id + " - Program Name: "
      @subject.programs.each do |program|
        str_temp += program.program_name + ", "
      end
      str_temp += "End "
      render plain: str_temp.inspect
    end
end
