class PersonalProgramsController < ApplicationController
  before_action :set_personal_program, only: [:show, :edit, :update, :destroy]

  # GET /personal_programs
  # GET /personal_programs.json
  def index
    @ku_user = current_user
    @my_personal_programs = @ku_user.personal_programs.where("user_personal_programs.status = 'install'")
    @all_personal_programs = PersonalProgram.where.not(id: @my_personal_programs)
  end

  # GET /personal_programs/1
  # GET /personal_programs/1.json
  def show
  end

  # GET /personal_programs/new
  def new
    @personal_program = PersonalProgram.new
  end

  # GET /personal_programs/1/edit
  def edit
    @personal_program = PersonalProgram.find(params[:id])
  end

  # POST /personal_programs
  # POST /personal_programs.json
  def create
    @personal_program = PersonalProgram.new(personal_program_params)

    respond_to do |format|
      if @personal_program.save
        format.html { redirect_to personal_programs_path, notice: @personal_program.program_name + ' was successfully created.' }
        format.json { render :show, status: :created, location: @personal_program }
      else
        format.html { render :new }
        format.json { render json: @personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personal_programs/1
  # PATCH/PUT /personal_programs/1.json
  def update
    respond_to do |format|
      if @personal_program.update(personal_program_params)
        format.html { redirect_to @personal_program, notice: @personal_program.program_name + ' was successfully updated.' }
        format.json { render :show, status: :ok, location: @personal_program }
      else
        format.html { render :edit }
        format.json { render json: @personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personal_programs/1
  # DELETE /personal_programs/1.json
  def destroy
    @personal_program.destroy
    respond_to do |format|
      format.html { redirect_to personal_programs_url, notice: 'Personal program was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personal_program
      @personal_program = PersonalProgram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def personal_program_params
      params.require(:personal_program).permit(:program_name, :note)
    end
end
