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
    if !params[:program_id].nil?
      @program = Program.find(params[:program_id])
    else
      @program = nil
    end
    @property_count = 0
    case @chef_resource.resource_type
    when "Repository"
      if !@chef_resource.chef_properties.any?
        @chef_resource.chef_properties.build
      end
    when "Download", "Extract", "Deb", "Source"
      if !@chef_resource.chef_properties.any?
        @chef_resource.chef_properties.build
        @chef_resource.chef_properties.build
      end
    end
  end

  # POST /chef_resources
  # POST /chef_resources.json
  def create
    @chef_resource = ChefResource.new(chef_resource_params)

    respond_to do |format|
      if @chef_resource.save
        format.html { redirect_to edit_chef_resource_path(@chef_resource), notice: 'Chef resource was successfully updated.' }
        format.json { render :show, status: :created, location: edit_chef_resource_path(@chef_resource) }
      else
        format.html { render :new }
        format.json { render json: @chef_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chef_resources/1
  # PATCH/PUT /chef_resources/1.json
  def update
    if !params[:program_id].nil?
      @program = Program.find(params[:program_id])
    else
      @program = nil
    end
    @property_count = 0
    respond_to do |format|
      if @chef_resource.update(chef_resource_params)
        format.html { redirect_to edit_chef_resource_path(@chef_resource), :flash => { :success => "Action was successfully updated." } }
        format.json { render :show, status: :ok, location: edit_chef_resource_path(@chef_resource) }
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
      params.require(:chef_resource).permit(:resource_type, chef_properties_attributes: [ :id, :value, :value_type ])
    end

    def find_unuse_program_and_file
      case @chef_resource.resource_type
      when "Repository" # delete program when program_name diff
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          chef_property = ChefProperty.find(value[:id])
          if chef_property.value != value[:value]
            diff_program_name = find_diff_program_name(chef_property.value, value[:value])
            # delete program
          end
        end
      when "Deb" # delete program when source file change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if value[:value_type] == "source_file"
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              # delete program
            end
          end
        end
      when "Source" # delete program when source file change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if value[:value_type] == "source_file"
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              # delete program
            end
          end
        end
      when "Download" # delete download file when url OR!!!! source file change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          chef_property = ChefProperty.find(value[:id])
          if chef_property.value != value[:value]
            # {"0"=>{"value"=>"aaaa", "value_type"=>"download_url", "id"=>"2"}, "1"=>{"value"=>"bbb", "value_type"=>"source_file", "id"=>"3"}}
            # use id of value_type = source_file
          end
        end
      when "Extract" # ( delete source and extract_to file when source change) or ( delete extract_to file when extract_to change )
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if value[:value_type] == "source_file"
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              # delete source
              # delete extract_to
            end
          else # extract_to
            # delete extract_to
          end
        end
      end
    end

    def add_remove_resource
      #
    end

    def find_diff_program_name(resource1, resource2)
      array1 = resource1.split(' ')
      array2 = resource2.split(' ')
      return (array1 - array2).join(" ")
    end

end
