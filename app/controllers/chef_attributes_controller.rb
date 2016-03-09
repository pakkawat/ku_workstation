class ChefAttributesController < ApplicationController
  before_action :set_chef_attribute, only: [:show, :edit, :update, :destroy]

  # GET /attributes
  # GET /attributes.json
  def index
    @chef_attributes = ChefAttribute.all
  end

  # GET /attributes/1
  # GET /attributes/1.json
  def show
  end

  # GET /attributes/new
  def new
    @chef_attribute = ChefAttribute.new
  end

  # GET /attributes/1/edit
  def edit
  end

  # POST /attributes
  # POST /attributes.json
  def create
    @chef_attribute = ChefAttribute.new(attribute_params)

    respond_to do |format|
      if @chef_attribute.save
        format.html { redirect_to @chef_attribute, notice: 'ChefAttribute was successfully created.' }
        format.json { render :show, status: :created, location: @chef_attribute }
      else
        format.html { render :new }
        format.json { render json: @chef_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attributes/1
  # PATCH/PUT /attributes/1.json
  def update
    respond_to do |format|
      if @chef_attribute.update(attribute_params)
        format.html { redirect_to @chef_attribute, notice: 'ChefAttribute was successfully updated.' }
        format.json { render :show, status: :ok, location: @chef_attribute }
      else
        format.html { render :edit }
        format.json { render json: @chef_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attributes/1
  # DELETE /attributes/1.json
  def destroy
    @chef_attribute.destroy
    respond_to do |format|
      format.html { redirect_to attributes_url, notice: 'ChefAttribute was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attribute
      @chef_attribute = ChefAttribute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attribute_params
      params.require(:chef_attribute).permit(:name, :value, :chef_property_id)
    end
end
