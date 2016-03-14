class ChefValuesController < ApplicationController
  before_action :set_chef_value, only: [:show, :edit, :update, :destroy]

  # GET /chef_values
  # GET /chef_values.json
  def index
    @chef_values = ChefValue.all
  end

  # GET /chef_values/1
  # GET /chef_values/1.json
  def show
  end

  # GET /chef_values/new
  def new
    @chef_value = ChefValue.new
  end

  # GET /chef_values/1/edit
  def edit
  end

  # POST /chef_values
  # POST /chef_values.json
  def create
    @chef_value = ChefValue.new(chef_value_params)

    respond_to do |format|
      if @chef_value.save
        format.html { redirect_to @chef_value, notice: 'Chef value was successfully created.' }
        format.json { render :show, status: :created, location: @chef_value }
      else
        format.html { render :new }
        format.json { render json: @chef_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chef_values/1
  # PATCH/PUT /chef_values/1.json
  def update
    respond_to do |format|
      if @chef_value.update(chef_value_params)
        format.html { redirect_to @chef_value, notice: 'Chef value was successfully updated.' }
        format.json { render :show, status: :ok, location: @chef_value }
      else
        format.html { render :edit }
        format.json { render json: @chef_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chef_values/1
  # DELETE /chef_values/1.json
  def destroy
    @chef_value.destroy
    respond_to do |format|
      format.html { redirect_to chef_values_url, notice: 'Chef value was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chef_value
      @chef_value = ChefValue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chef_value_params
      params.require(:chef_value).permit(:chef_attribute_id, :ku_user_id, :value)
    end
end
