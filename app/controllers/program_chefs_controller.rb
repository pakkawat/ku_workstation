class ProgramChefsController < ApplicationController
  before_action :set_program_chef, only: [:show, :edit, :update, :destroy]

  # GET /program_chefs
  # GET /program_chefs.json
  def index
    @program_chefs = ProgramChef.all
  end

  # GET /program_chefs/1
  # GET /program_chefs/1.json
  def show
  end

  # GET /program_chefs/new
  def new
    @program_chef = ProgramChef.new
  end

  # GET /program_chefs/1/edit
  def edit
  end

  # POST /program_chefs
  # POST /program_chefs.json
  def create
    @program_chef = ProgramChef.new(program_chef_params)

    respond_to do |format|
      if @program_chef.save
        format.html { redirect_to @program_chef, notice: 'Program chef was successfully created.' }
        format.json { render :show, status: :created, location: @program_chef }
      else
        format.html { render :new }
        format.json { render json: @program_chef.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /program_chefs/1
  # PATCH/PUT /program_chefs/1.json
  def update
    respond_to do |format|
      if @program_chef.update(program_chef_params)
        format.html { redirect_to @program_chef, notice: 'Program chef was successfully updated.' }
        format.json { render :show, status: :ok, location: @program_chef }
      else
        format.html { render :edit }
        format.json { render json: @program_chef.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /program_chefs/1
  # DELETE /program_chefs/1.json
  def destroy
    @program_chef.destroy
    respond_to do |format|
      format.html { redirect_to program_chefs_url, notice: 'Program chef was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_program_chef
      @program_chef = ProgramChef.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def program_chef_params
      params[:program_chef]
    end
end
