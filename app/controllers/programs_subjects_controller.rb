class ProgramsSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])
    @subjectprograms = Program.where(id: @subject.programs_subjects.select("program_id").where(program_enabled: true)).order("program_name ASC")
    @programs = Program.where.not(id: @subject.programs_subjects.select("program_id").where(program_enabled: true)).order("program_name ASC")
  end

  def create
    @program = Program.find(params[:program_id])
    @subject = Subject.find(params[:subject_id])
    #@subject.programs_subjects.create(program: @program)
    #add_program_to_run_list
    #redirect_to subject_programs_subjects_path(:subject_id => @subject.id)


    @program_enabled = @subject.programs_subjects.find_by(program_id: @program.id)
    if @program_enabled.present?
      if @program_enabled.update_attribute(:program_enabled, true)
        #add_user_programs
        flash[:success] = @program.program_name + " has been added"
      else
        flash[:danger] = "Error1!!"
      end
    else
      if @subject.programs_subjects.create(program: @program)
        #add_user_programs
        flash[:success] = @program.program_name + " has been added"
      else
        flash[:danger] = "Error2!!"
      end
    end#@program_enabled.present?
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    @program = Program.find(params[:program_id])
    @subject = Subject.find(params[:subject_id])
    #ProgramsSubject.find_by(program_id: @program.id, subject_id: @subject.id).destroy
    #add_remove_program_to_run_list
    #redirect_to subject_programs_subjects_path(:subject_id => @subject.id)

    if @subject.programs_subjects.find_by(program_id: @program.id).update_attribute(:program_enabled, false)
      #remove_user_programs
      flash[:success] = @program.program_name + " has been deleted from subject"
    else
      flash[:danger] = "Error3!!"
    end
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)
  end

  def program_apply# send run_list to Chef-server and run sudo chef-clients then if any remove need update user.run_list
    str_temp = ""
    @subject = Subject.find(params[:subject_id])
    #@subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
      #if !user.run_list.blank?
        #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        #str_temp += " || "
      #end
    #end

    #users = @subject.ku_users
    @job = Delayed::Job.enqueue ProgramsSubjectJob.new(@subject)
    str_des = "Apply change on Subject:"+@subject.subject_name
    @job.update_column(:description, str_des)
    #@subject.programs.where("programs_subjects.program_enabled = false").each do |program|
      #@subject.ku_users.each do |user|
        # delete recipe[remove-xxx], from user.run_list
        #user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
      #end
    #end
    # delete relationship
    #@subject.programs_subjects.where(program_enabled: false).destroy_all
    #flash[:success] = str_temp
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)

  end

  private
    def add_program_to_run_list # mark not use
      str_temp = ""
      #@program = Program.find(params[:program_id])
      #@subject = Subject.find(params[:subject_id])
      @subject.ku_users.where("user_subjects.user_enabled = true").each do |user|
        #str_temp += "ku_id: " + user.ku_id + " add recipe[" + @program.program_name + "] || "
        if !user.run_list.to_s.include?("recipe[" + @program.program_name + "],")
          user.update_column(:run_list, user.run_list.to_s + "recipe[" + @program.program_name + "],")
        end
      end
      #KuUser.where.not(id: @subject.ku_users).update_all(:run_list => true)
    end

    def add_remove_program_to_run_list # mark not use
      str_temp = ""
      #@program = Program.find(params[:program_id])
      #@subject = Subject.find(params[:subject_id])
      @subject.ku_users.where("user_subjects.user_enabled = true").each do |user|
        if other_user_subject_use_this_program(user)
          user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", "recipe[remove-" + @program.program_name + "],"))
        end
      end
    end

    def update_program_to_run_list # mark not use
      str_temp = ""
      @subject.ku_users.where("user_subjects.user_enabled = true").each do |user|
        user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + @program.program_name + "],", "recipe[" + @program.program_name + "],"))
      end
    end
    #user.subjects.where(id: ProgramsSubject.select("subject_id").where(:program_id => @program.id, :program_enabled => true).where.not(subject_id: @subject.id)).empty?
    def other_user_subject_use_this_program(user) # mark not use
      return user.subjects.where(id: ProgramsSubject.select("subject_id").where(:program_id => @program.id, :program_enabled => true).where.not(subject_id: @subject.id)).empty?
    end

    def add_user_programs # mark not use
      str_temp = ""
      @subject.ku_users.where("user_subjects.user_enabled = true").each do |user|
        add_user_config(user)
        @program.users_programs.create(:ku_user_id => user.id, :subject_id => @subject.id)
      end
    end

    def remove_user_programs # mark not use
      str_temp = ""
      @subject.ku_users.where("user_subjects.user_enabled = true").each do |user|
        delete_user_config(user)
        @program.users_programs.where(:ku_user_id => user.id, :subject_id => @subject.id).destroy_all
      end
    end

    def add_user_config(user) # mark not use
      chef_attributes = ChefAttribute.where(chef_resource_id: @program.chef_resources.pluck("id"))
      chef_attributes.each do |chef_attribute|
        ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: user).first_or_create
      end
    end

    def delete_user_config(user) # mark not use
      chef_attributes = ChefAttribute.where(chef_resource_id: @program.chef_resources.pluck("id"))
      user.chef_values.where(chef_attribute_id: chef_attributes).destroy_all
    end
end
