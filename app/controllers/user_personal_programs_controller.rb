class UserPersonalProgramsController < ApplicationController
  before_action :set_user_personal_program, only: [:show, :edit, :update]

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
    @ku_user = current_user
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    user_personal_program = @ku_user.user_personal_programs.find_by(personal_program_id: @personal_program)
    if user_personal_program.present?
      respond_to do |format|
        if user_personal_program.update_attribute(:status, "install")
          format.html { redirect_to personal_programs_path, notice: 'Personal program was successfully added.' }
          format.json { render :show, status: :created, location: personal_programs_path }
        else
          format.html { redirect_to personal_programs_path }
          format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @ku_user.user_personal_programs.create(personal_program: @personal_program, status: "install")
          format.html { redirect_to personal_programs_path, notice: 'Personal program was successfully added.' }
          format.json { render :show, status: :created, location: personal_programs_path }
        else
          format.html { redirect_to personal_programs_path }
          format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
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
    @ku_user = current_user
    @personal_program = PersonalProgram.find(params[:personal_program_id])

    respond_to do |format|
      if @ku_user.user_personal_programs.find_by(personal_program_id: @personal_program.id).update_attribute(:status, "uninstall")
        format.html { redirect_to personal_programs_path, notice: 'Personal program was successfully deleted.' }
        format.json { render :show, status: :created, location: personal_programs_path }
      else
        format.html { redirect_to personal_programs_path }
        format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
      end
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
