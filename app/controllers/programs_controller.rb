class ProgramsController < ApplicationController
  def index
    @programs = Program.all.paginate(page: params[:page], per_page: 2)
  end
  
  def show
    @program = Program.find(params[:id])
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new(subject_params)
    #render plain: ku_user_params.inspect
    #@KuUser.save
    if @program.save
      redirect_to programs_path, :notice => "Program was saved"
    else
      render "new"
    end
  end

  def edit
    @program = Program.find(params[:id])
  end

  def update
    @program = Program.find(params[:id])

    if @program.update_attributes(program_params)
      redirect_to programs_path, :notice => "Program has been updated"
    else
      render "edit"
    end
  end

  def destroy
    @program = Program.find(params[:id])
    @program.destroy
    redirect_to programs_path, :notice => "Program has been deleted"
  end

  private
    def program_params
      params.require(:program).permit(:program_name, :note)
    end

end
