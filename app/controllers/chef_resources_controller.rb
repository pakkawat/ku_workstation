class ChefResourcesController < ApplicationController
  before_action :set_chef_resource, only: [:show, :edit, :update, :destroy]

  # GET /chef_resources
  # GET /chef_resources.json
  def index
    @chef_resources = ChefResource.all
  end

  # GET /chef_resources/1
  # GET /chef_resources/1.json
  def show
  end

  # GET /chef_resources/new
  def new
    @chef_resource = ChefResource.new
  end

  # GET /chef_resources/1/edit
  def edit
  end

  # POST /chef_resources
  # POST /chef_resources.json
  def create
    @chef_resource = ChefResource.new(chef_resource_params)

    respond_to do |format|
      if @chef_resource.save
        format.html { redirect_to @chef_resource, notice: 'Chef resource was successfully created.' }
        format.json { render :show, status: :created, location: @chef_resource }
      else
        format.html { render :new }
        format.json { render json: @chef_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chef_resources/1
  # PATCH/PUT /chef_resources/1.json
  def update
    respond_to do |format|
      if @chef_resource.update(chef_resource_params)
        format.html { redirect_to @chef_resource, notice: 'Chef resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @chef_resource }
      else
        format.html { render :edit }
        format.json { render json: @chef_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chef_resources/1
  # DELETE /chef_resources/1.json
  def destroy
    @chef_resource.destroy
    respond_to do |format|
      format.html { redirect_to chef_resources_url, notice: 'Chef resource was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chef_resource
      @chef_resource = ChefResource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chef_resource_params
      params.require(:chef_resource).permit(:resource_type)
    end
end
