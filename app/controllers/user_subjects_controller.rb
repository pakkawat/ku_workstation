class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectusers = KuUser.where(id: @subject.user_subjects.select("ku_user_id").where(user_enabled: true)).order("ku_id ASC")
    @kuusers = KuUser.where.not(id: @subject.user_subjects.select("ku_user_id").where(user_enabled: true)).order("ku_id ASC")
  end

  def create
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    @user_enabled = @subject.user_subjects.find_by(ku_user_id: @kuuser.id)
    if @user_enabled.present?
      if @user_enabled.update_attribute(:user_enabled, true)
        update_program_to_run_list
        flash[:success] = @kuuser.ku_id + " has been added"
      else
        flash[:danger] = "Error1!!"
      end
    else
      if @subject.user_subjects.create(ku_user: @kuuser)
        add_program_to_run_list
        flash[:success] = @kuuser.ku_id + " has been added"
      else
        flash[:danger] = "Error2!!"
      end
    end#@user_enabled.present?
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    #UserSubject.find_by(ku_user_id: @kuuser.id, subject_id: @subject.id).destroy
    if @subject.user_subjects.find_by(ku_user_id: @kuuser.id).update_attribute(:user_enabled, false)
      add_remove_program_to_run_list
      flash[:success] = @kuuser.ku_id + " has been deleted from subject"
    else
      flash[:danger] = "Error3!!"
    end
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  def subject_apply# send run_list to Chef-server and run sudo chef-clients then if any remove need update user.run_list
    str_temp = ""
    @subject = Subject.find(params[:subject_id])
    #@subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
      #if !user.run_list.blank?
        #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        #str_temp += " || "
      #end
    #end

    #users = @subject.ku_users
    @job = Delayed::Job.enqueue UserSubjectJob.new(@subject)

    #@subject.ku_users.where("user_subjects.user_enabled = false").each do |user|
      #@subject.programs.each do |program|
        # delete recipe[remove-xxx], from user.run_list
        #user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
      #end
    #end
    # delete relationship
    #@subject.user_subjects.where(user_enabled: false).destroy_all
    #flash[:success] = str_temp
    flash[:success] = "Apply change on Subject:"+@subject.subject_name+" with Job ID:"+@job.id
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)

  end

  private
    def add_program_to_run_list
      str_temp = ""
      #@kuuser = KuUser.find(params[:ku_user_id])
      #@subject = Subject.find(params[:subject_id])

      @subject.programs.where("programs_subjects.program_enabled = true").each do |program|
        #str_temp += "ku_id: " + user.ku_id + " add recipe[" + @program.program_name + "] || "
        if !@kuuser.run_list.to_s.include?("recipe[" + program.program_name + "],")
          @kuuser.update_column(:run_list, @kuuser.run_list.to_s + "recipe[" + program.program_name + "],")
        end
      end
      #KuUser.where.not(id: @subject.ku_users).update_all(:run_list => true)
    end

    def add_remove_program_to_run_list
      str_temp = ""
      #@kuuser = KuUser.find(params[:ku_user_id])
      #@subject = Subject.find(params[:subject_id])
      @subject.programs.where("programs_subjects.program_enabled = true").each do |program|
        if other_user_subject_use_this_program(program)
          @kuuser.update_column(:run_list, @kuuser.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"))
        end
      end
    end

    def update_program_to_run_list
      str_temp = ""
      @subject.programs.where("programs_subjects.program_enabled = true").each do |program|
        @kuuser.update_column(:run_list, @kuuser.run_list.gsub("recipe[remove-" + program.program_name + "],", "recipe[" + program.program_name + "],"))
      end
    end

    def other_user_subject_use_this_program(program)
      #return @kuuser.subjects.where(subject_id: Subject.select("subject_id").where(id: ProgramsSubject.select("subject_id").where(:program_id => program.id, :program_enabled => true).where.not(subject_id: @subject.id))).empty?
      return @kuuser.subjects.where(id: ProgramsSubject.select("subject_id").where(:program_id => program.id, :program_enabled => true).where.not(subject_id: @subject.id)).empty?
    end
end
