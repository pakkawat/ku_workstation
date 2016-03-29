class PersonalProgramChefsController < ApplicationController
  before_action :set_personal_program_chef, only: [:show, :edit, :update, :destroy]

  # GET /personal_program_chefs
  # GET /personal_program_chefs.json
  def index
    @personal_program_chefs = PersonalProgramChef.all
  end

  # GET /personal_program_chefs/1
  # GET /personal_program_chefs/1.json
  def show
  end

  # GET /personal_program_chefs/new
  def new
    @personal_program_chef = PersonalProgramChef.new
  end

  # GET /personal_program_chefs/1/edit
  def edit
  end

  # POST /personal_program_chefs
  # POST /personal_program_chefs.json
  def create
    @personal_program_chef = PersonalProgramChef.new(personal_program_chef_params)

    respond_to do |format|
      if @personal_program_chef.save
        format.html { redirect_to @personal_program_chef, notice: 'Personal program chef was successfully created.' }
        format.json { render :show, status: :created, location: @personal_program_chef }
      else
        format.html { render :new }
        format.json { render json: @personal_program_chef.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personal_program_chefs/1
  # PATCH/PUT /personal_program_chefs/1.json
  def update
    respond_to do |format|
      if @personal_program_chef.update(personal_program_chef_params)
        format.html { redirect_to @personal_program_chef, notice: 'Personal program chef was successfully updated.' }
        format.json { render :show, status: :ok, location: @personal_program_chef }
      else
        format.html { render :edit }
        format.json { render json: @personal_program_chef.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personal_program_chefs/1
  # DELETE /personal_program_chefs/1.json
  def destroy
    @personal_program_chef.destroy
    respond_to do |format|
      format.html { redirect_to personal_program_chefs_url, notice: 'Personal program chef was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personal_program_chef
      @personal_program_chef = PersonalProgramChef.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def personal_program_chef_params
      params.require(:personal_program_chef).permit(:personal_chef_resource_id, :personal_program_id)
    end
end
