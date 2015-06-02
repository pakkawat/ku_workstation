class ProgramsSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectprograms = @subject.programs.paginate(page: params[:subjectprogram_page], per_page: 2).order("program_name ASC")
    @programs = Program.where.not(id: @subject.programs).paginate(page: params[:program_page], per_page: 2).order("program_name ASC")
  end

  def create
    @program = Program.find(params[:program_id])
    @subject = Subject.find(params[:subject_id])
    @subject.programs_subjects.create(program: @program)
    add_program_to_run_list
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    @program = Program.find(params[:program_id])
    @subject = Subject.find(params[:subject_id])
    ProgramsSubject.find_by(program_id: @program.id, subject_id: @subject.id).destroy
    add_remove_program_to_run_list
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)
  end

  private
    def program_apply# send run_list to Chef-server and run sudo chef-clients then if any remove need update user.run_list
      str_temp = ""
      @subject = Subject.find(params[:subject_id])
      @subject.ku_users.each do |user|
        str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        str_temp += " || "
        # delete recipe[remove-xxx], from user.run_list
      end

      render plain: str_temp.inspect
    end

    def add_program_to_run_list
      str_temp = ""
      @subject.ku_users.each do |user|
        #str_temp += "ku_id: " + user.ku_id + " add recipe[" + @program.program_name + "] || "
        user.update_column(:run_list, user.run_list + "recipe[" + @program.program_name + "],")
      end
      #KuUser.where.not(id: @subject.ku_users).update_all(:run_list => true)
    end

    def add_remove_program_to_run_list
      str_temp = ""
      @subject.ku_users.each do |user|
        user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", "recipe[remove-" + @program.program_name + "],"))
      end
    end
end
