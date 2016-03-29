class UserPersonalProgramsController < ApplicationController
  before_action :set_user_personal_program, only: [:show, :edit, :update, :destroy]

  # GET /user_personal_programs
  # GET /user_personal_programs.json
  def index
    @user_personal_programs = UserPersonalProgram.all
  end

  # GET /user_personal_programs/1
  # GET /user_personal_programs/1.json
  def show
  end

  # GET /user_personal_programs/new
  def new
    @user_personal_program = UserPersonalProgram.new
  end

  # GET /user_personal_programs/1/edit
  def edit
  end

  # POST /user_personal_programs
  # POST /user_personal_programs.json
  def create
    @user_personal_program = UserPersonalProgram.new(user_personal_program_params)

    respond_to do |format|
      if @user_personal_program.save
        format.html { redirect_to @user_personal_program, notice: 'User personal program was successfully created.' }
        format.json { render :show, status: :created, location: @user_personal_program }
      else
        format.html { render :new }
        format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_personal_programs/1
  # PATCH/PUT /user_personal_programs/1.json
  def update
    respond_to do |format|
      if @user_personal_program.update(user_personal_program_params)
        format.html { redirect_to @user_personal_program, notice: 'User personal program was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_personal_program }
      else
        format.html { render :edit }
        format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_personal_programs/1
  # DELETE /user_personal_programs/1.json
  def destroy
    @user_personal_program.destroy
    respond_to do |format|
      format.html { redirect_to user_personal_programs_url, notice: 'User personal program was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_personal_program
      @user_personal_program = UserPersonalProgram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_personal_program_params
      params.require(:user_personal_program).permit(:ku_user_id, :personal_program_id, :status)
    end
end
