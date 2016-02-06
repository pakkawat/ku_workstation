class ChefPropertiesController < ApplicationController
  before_action :set_chef_property, only: [:show, :edit, :update, :destroy]

  # GET /chef_properties
  # GET /chef_properties.json
  def index
    @chef_properties = ChefProperty.all
  end

  # GET /chef_properties/1
  # GET /chef_properties/1.json
  def show
  end

  # GET /chef_properties/new
  def new
    @chef_property = ChefProperty.new
  end

  # GET /chef_properties/1/edit
  def edit
  end

  # POST /chef_properties
  # POST /chef_properties.json
  def create
    @chef_property = ChefProperty.new(chef_property_params)

    respond_to do |format|
      if @chef_property.save
        format.html { redirect_to @chef_property, notice: 'Chef property was successfully created.' }
        format.json { render :show, status: :created, location: @chef_property }
      else
        format.html { render :new }
        format.json { render json: @chef_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chef_properties/1
  # PATCH/PUT /chef_properties/1.json
  def update
    respond_to do |format|
      if @chef_property.update(chef_property_params)
        format.html { redirect_to @chef_property, notice: 'Chef property was successfully updated.' }
        format.json { render :show, status: :ok, location: @chef_property }
      else
        format.html { render :edit }
        format.json { render json: @chef_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chef_properties/1
  # DELETE /chef_properties/1.json
  def destroy
    @chef_property.destroy
    respond_to do |format|
      format.html { redirect_to chef_properties_url, notice: 'Chef property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chef_property
      @chef_property = ChefProperty.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chef_property_params
      params.require(:chef_property).permit(:value)
    end
end
