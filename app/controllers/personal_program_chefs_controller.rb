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
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    @personal_chef_resource = PersonalChefResource.new(resource_type: params[:chef_resource_type])

    respond_to do |format|
      if @personal_program.personal_program_chefs.create(personal_chef_resource: @personal_chef_resource)
        format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :success => "Action was successfully created." } }
        format.json { render :show, status: :created, location: edit_personal_program_path(@personal_program) }
      else
        format.html { render :new }
        format.json { render json: @personal_program.errors, status: :unprocessable_entity }
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
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    @personal_chef_resource = PersonalChefResource.find(@personal_program_chef.personal_chef_resource_id)
    add_remove_resource
    @personal_program_chef.destroy
    respond_to do |format|
      format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :success => "Action was successfully destroyed." } }
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


    def add_remove_resource
      @ku_user = current_user
      if @personal_chef_resource.resource_type == "Repository" # repo not check chef_resource_id because install from repo will have one or more program
        value = @personal_chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
        @personal_program.ku_users.each do |user|
          user.user_remove_resources.create(personal_program_id: @personal_program.id, personal_chef_resource_id: @personal_chef_resource.id, resource_type: @personal_chef_resource.resource_type, value: value, value_type: "program")
        end
      else
        @personal_program.ku_users.each do |user|
          if !user.user_remove_resources.find_by(personal_chef_resource_id: @personal_chef_resource.id).present? # check Is chef_resource_id alredy in remove_resources
            value = nil
            value_type = nil
            case @personal_chef_resource.resource_type
            when "Deb"
              value = @personal_chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
              value_type = "program"
            when "Source"
              value = @personal_chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
              value_type = "program"
            when "Download"
              value = @personal_chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
              value_type = "file"
            when "Extract"
              value = @personal_chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value).first
              value_type = "folder"
            when "Config_file"

              value = @personal_chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
              #delete_config_file_in_templates(value)
              value_type = "file"
            when "Copy_file"
              value = @personal_chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
              value_type = @personal_chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value).first
            when "Create_file"

              value = @personal_chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value).first
              #delete_file_in_templates(value)
              value_type = "file"
            when "Move_file"
              source_file = @personal_chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
              value = @personal_chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
              src_file_extname = File.extname(source_file)
              if src_file_extname == ""
                value_type = "folder"
              else
                value_type = "file"
              end
            when "Bash_script"
              value = "_" + @personal_chef_resource.id.to_s
              value_type = "file"

            when "Execute_command"
              value = @personal_chef_resource.chef_properties.where(:value_type => "execute_command").pluck(:value).first
              value_type = "command"
            end
            user.user_remove_resources.create(personal_program_id: @personal_program.id, personal_chef_resource_id: @personal_chef_resource.id, resource_type: @personal_chef_resource.resource_type, value: value, value_type: value_type)
          end
        end
      end
    end

end
