class PersonalChefResourcesController < ApplicationController
  before_action :set_personal_chef_resource, only: [:show, :edit, :update, :destroy]

  # GET /personal_chef_resources
  # GET /personal_chef_resources.json
  def index
    @personal_chef_resources = PersonalChefResource.all
  end

  # GET /personal_chef_resources/1
  # GET /personal_chef_resources/1.json
  def show
  end

  # GET /personal_chef_resources/new
  def new
    @personal_chef_resource = PersonalChefResource.new
  end

  # GET /personal_chef_resources/1/edit
  def edit
  end

  # POST /personal_chef_resources
  # POST /personal_chef_resources.json
  def create
    @personal_chef_resource = PersonalChefResource.new(personal_chef_resource_params)

    respond_to do |format|
      if @personal_chef_resource.save
        format.html { redirect_to @personal_chef_resource, notice: 'Personal chef resource was successfully created.' }
        format.json { render :show, status: :created, location: @personal_chef_resource }
      else
        format.html { render :new }
        format.json { render json: @personal_chef_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personal_chef_resources/1
  # PATCH/PUT /personal_chef_resources/1.json
  def update
    respond_to do |format|
      if @personal_chef_resource.update(personal_chef_resource_params)
        format.html { redirect_to @personal_chef_resource, notice: 'Personal chef resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @personal_chef_resource }
      else
        format.html { render :edit }
        format.json { render json: @personal_chef_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personal_chef_resources/1
  # DELETE /personal_chef_resources/1.json
  def destroy
    @personal_chef_resource.destroy
    respond_to do |format|
      format.html { redirect_to personal_chef_resources_url, notice: 'Personal chef resource was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personal_chef_resource
      @personal_chef_resource = PersonalChefResource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def personal_chef_resource_params
      params.require(:personal_chef_resource).permit(:resource_type, :priority)
    end
end
