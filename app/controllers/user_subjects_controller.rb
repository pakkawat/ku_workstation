class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])
    @subjectusers = @subject.ku_users.order("ku_id ASC")
    @kuusers = KuUser.where.not(id: @subjectusers).order("ku_id ASC")
  end

  def create
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    @user_enabled = @subject.user_subjects.find_by(ku_user_id: @kuuser.id)
    if @user_enabled.present?
      if @user_enabled.update(user_enabled: true, state: "none")
        #add_user_programs
        flash[:success] = @kuuser.ku_id + " has changed state to normal"
      else
        flash[:danger] = "Error1!!"
      end
    else
      if @subject.user_subjects.create(ku_user: @kuuser, state: "new")
        #add_user_programs
        flash[:success] = @kuuser.ku_id + " has changed state to new"
      else
        flash[:danger] = "Error2!!"
      end
    end#@user_enabled.present?
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    user_subject = UserSubject.find(params[:id])
    @kuuser = KuUser.find(user_subject.ku_user_id)
    @subject = Subject.find(params[:subject_id])
    state = ""

    check_error = true
    if user_subject.applied
      check_error = user_subject.update(user_enabled: false, state: "remove")
      state = "remove"
    else
      check_error = user_subject.destroy
    end

    if check_error
      if state == ""
        flash[:success] = @kuuser.ku_id + " has deleted from subject"
      else
        flash[:success] = @kuuser.ku_id + " has changed state to remove"
      end
    else
      flash[:danger] = "delete error"
    end

    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  def subject_apply# send run_list to Chef-server and run sudo chef-clients then if any remove need update user.run_list
    #str_temp = ""
    @subject = Subject.find(params[:subject_id])
    #@subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
      #if !user.run_list.blank?
        #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        #str_temp += " || "
      #end
    #end

    #users = @subject.ku_users
    @job = Delayed::Job.enqueue UserSubjectJob.new(@subject)
    str_des = "Apply change on Subject:"+@subject.subject_name
    @job.update_column(:description, str_des)
    #@subject.ku_users.where("user_subjects.user_enabled = false").each do |user|
      #@subject.programs.each do |program|
        # delete recipe[remove-xxx], from user.run_list
        #user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
      #end
    #end
    # delete relationship
    #@subject.user_subjects.where(user_enabled: false).destroy_all
    #flash[:success] = str_temp
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)

  end

  private
    def add_program_to_run_list # mark not use
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

    def add_remove_program_to_run_list # mark not use
      str_temp = ""
      #@kuuser = KuUser.find(params[:ku_user_id])
      #@subject = Subject.find(params[:subject_id])
      @subject.programs.where("programs_subjects.program_enabled = true").each do |program|
        if other_user_subject_use_this_program(program)
          @kuuser.update_column(:run_list, @kuuser.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"))
        end
      end
    end

    def other_user_subject_use_this_program(program) # mark not use
      #return @kuuser.subjects.where(subject_id: Subject.select("subject_id").where(id: ProgramsSubject.select("subject_id").where(:program_id => program.id, :program_enabled => true).where.not(subject_id: @subject.id))).empty?
      return @kuuser.subjects.where(id: ProgramsSubject.select("subject_id").where(:program_id => program.id, :program_enabled => true).where.not(subject_id: @subject.id)).empty?
    end

    def add_user_programs # mark not use
      str_temp = ""
      @subject.programs.where("programs_subjects.program_enabled = true").each do |program|
        @kuuser.users_programs.create(:program_id => program.id, :subject_id => @subject.id)
        add_user_config(program)
      end
    end

    def remove_user_programs # mark not use
      str_temp = ""
      @subject.programs.where("programs_subjects.program_enabled = true").each do |program|
        delete_user_config(program)
        @kuuser.users_programs.where(:program_id => program.id, :subject_id => @subject.id).destroy_all
      end
    end

    def add_user_config(program) # mark not use
      chef_attributes = ChefAttribute.where(chef_resource_id: program.chef_resources.pluck("id"))
      chef_attributes.each do |chef_attribute|
        ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: @kuuser).first_or_create
      end
    end

    def delete_user_config(program) # mark not use
      chef_attributes = ChefAttribute.where(chef_resource_id: program.chef_resources.pluck("id"))
      @kuuser.chef_values.where(chef_attribute_id: chef_attributes).destroy_all
    end
end
