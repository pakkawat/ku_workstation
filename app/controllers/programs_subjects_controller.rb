class ProgramsSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectprograms = Program.where(id: @subject.programs_subjects.select("program_id").where(program_enabled: true)).paginate(page: params[:subjectprogram_page], per_page: 2).order("program_name ASC")
    @programs = Program.where.not(id: @subject.programs_subjects.select("program_id").where(program_enabled: true)).paginate(page: params[:program_page], per_page: 2).order("program_name ASC")
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
        update_program_to_run_list
        flash[:success] = @program.program_name + " has been added"
      else
        flash[:danger] = "Error1!!"
      end
    else
      if @subject.programs_subjects.create(program: @program)
        add_program_to_run_list
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
      add_remove_program_to_run_list
      flash[:success] = @program.program_name + " has been deleted from subject"
    else
      flash[:danger] = "Error3!!"
    end
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)
  end

  def program_apply# send run_list to Chef-server and run sudo chef-clients then if any remove need update user.run_list
    str_temp = ""
    @subject = Subject.find(params[:subject_id])
    @subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
      if !user.run_list.blank?
        str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        str_temp += " || "
      end
    end

    Program.where(id: @subject.programs_subjects.select("program_id").where(program_enabled: false)).each do |program|
      @subject.ku_users.each do |user|
        # delete recipe[remove-xxx], from user.run_list
        user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
      end
    end
    # delete relationship
    @subject.programs_subjects.where(program_enabled: false).destroy_all
    flash[:success] = str_temp
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)

  end

  private
    def add_program_to_run_list
      str_temp = ""
      #@program = Program.find(params[:program_id])
      #@subject = Subject.find(params[:subject_id])
      KuUser.where(id: @subject.user_subjects.select("ku_user_id").where(user_enabled: true)).each do |user|
        #str_temp += "ku_id: " + user.ku_id + " add recipe[" + @program.program_name + "] || "
        user.update_column(:run_list, user.run_list + "recipe[" + @program.program_name + "],")
      end
      #KuUser.where.not(id: @subject.ku_users).update_all(:run_list => true)
    end

    def add_remove_program_to_run_list
      str_temp = ""
      #@program = Program.find(params[:program_id])
      #@subject = Subject.find(params[:subject_id])
      KuUser.where(id: @subject.user_subjects.select("ku_user_id").where(user_enabled: true)).each do |user|
        user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", "recipe[remove-" + @program.program_name + "],"))
      end
    end

    def update_program_to_run_list
      str_temp = ""
      KuUser.where(id: @subject.user_subjects.select("ku_user_id").where(user_enabled: true)).each do |user|
        user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + @program.program_name + "],", "recipe[" + @program.program_name + "],"))
      end
    end
end
