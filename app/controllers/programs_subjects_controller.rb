class ProgramsSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectprograms = @subject.programs.paginate(page: params[:subjectprogram_page], per_page: 2).order("program_name DESC")
    @programs = Program.where.not(id: @subject.programs).paginate(page: params[:program_page], per_page: 2).order("program_name DESC")
  end

  def create
    @program = Program.find(params[:program_id])
    @subject = Subject.find(params[:subject_id])
    @subject.programs_subjects.create(program: @program)
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    @program = Program.find(params[:program_id])
    @subject = Subject.find(params[:subject_id])
    ProgramsSubject.find_by(program_id: @program.id, subject_id: @subject.id).destroy
    redirect_to subject_programs_subjects_path(:subject_id => @subject.id)
  end

  def apply_prgrams
    str_temp = ""
    @subject = Subject.find(params[:subject_id])
    @subject.ku_users.each do |user|
      str_temp += "ku_id: " + user.ku_id + " - Program Name: "
      @subject.programs.each do |program|
        str_temp += program.program_name + ", "
      end
      str_temp += "End "
    end

    render plain: str_temp.inspect
  end
end
