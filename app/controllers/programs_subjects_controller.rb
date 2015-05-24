class ProgramsSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectprograms = @subject.programs.paginate(page: params[:subjectprogram_page], per_page: 2)
    @programs = Program.where.not(id: @subjectprograms).paginate(page: params[:program_page], per_page: 2)
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
end
