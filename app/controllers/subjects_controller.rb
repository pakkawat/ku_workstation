class SubjectsController < ApplicationController
  def index
    @subjects = Subject.all
  end

  def show
    @subject = Subject.find(params[:id])
    @was_updated = @subject.ku_users.where("user_subjects.state != 'none'").count + @subject.programs.where("programs_subjects.state != 'none'").count
  end

  def new
    @subject = Subject.new
  end

  def create
    if params[:subject_name] != "" && params[:subject_id] != ""
      subject = Subject.new(subject_id: params[:subject_id], subject_name: params[:subject_name], term: params[:term], year: params[:year])
      if subject.save
        flash[:success] = "Subject was created"
      else
        flash[:danger] = "Create subject error."
      end
    else
      flash[:danger] = "Subject name and Subject id cannot be null or empty."
    end
    redirect_to dashboard_index_path
  end

  def create2
    @subject = Subject.new(subject_params)
    #render plain: ku_user_params.inspect
    #@KuUser.save
    if @subject.save
      flash[:success] = "Subject was saved"
      redirect_to subjects_path
    else
      render "new"
    end
  end

  def edit
    @subject = Subject.find(params[:id])
  end

  def update
    @subject = Subject.find(params[:id])

    if @subject.update_attributes(subject_params)
      flash[:success] = "Subject was successfully updated"
      redirect_to @subject
    else
      flash[:danger] = "Subject update error"
      redirect_to @subject
    end
  end

  def destroy
    @subject = Subject.find(params[:id])
    @job = Delayed::Job.enqueue SubjectJob.new(@subject.id,"delete")
    str_des = "Delete Subject:"+@subject.subject_name
    @job.update_attributes(:subject_id => @subject.id, :description => str_des, :owner => current_user.id)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    redirect_to dashboard_index_path
  end

  def apply_change
    @subject = Subject.find(params[:subject_id])
    @job = Delayed::Job.enqueue SubjectJob.new(@subject.id,"apply_change")
    str_des = "Apply change on Subject:"+@subject.subject_name
    @job.update_attributes(:subject_id => @subject.id, :description => str_des, :owner => current_user.id)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    redirect_to dashboard_index_path
  end

  private
    def subject_params
      params.require(:subject).permit(:subject_id, :subject_name, :term, :year)
    end


    def other_user_subject_use_this_program(user,program)
      #return user.subjects.where(subject_id: Subject.select("subject_id").where(id: ProgramsSubject.select("subject_id").where(:program_id => program.id, :program_enabled => true).where.not(subject_id: @subject.id))).empty?
      return user.subjects.where(id: ProgramsSubject.select("subject_id").where(:program_id => program.id, :program_enabled => true).where.not(subject_id: @subject.id)).empty?
    end
end
