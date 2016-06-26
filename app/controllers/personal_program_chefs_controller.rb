class PersonalProgramChefsController < ApplicationController
  #before_action :set_personal_program_chef, only: [:show, :edit, :update, :destroy]

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
    priority = 0
    if !@personal_program.personal_chef_resources.where(status: "install").last.nil?
      priority = @personal_program.personal_chef_resources.where(status: "install").last.priority
    end
    @personal_chef_resource = PersonalChefResource.new(resource_type: params[:chef_resource_type], priority: priority + 1)

    respond_to do |format|
      if @personal_program.personal_program_chefs.create(personal_chef_resource: @personal_chef_resource)
        UserPersonalProgram.where(:personal_program_id => @personal_program.id).update_all(:was_updated => true)
        UserPersonalProgram.where(:personal_program_id => @personal_program.id, :state => "none").update_all(:state => "update")
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
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    @personal_chef_resource = PersonalChefResource.find(params[:personal_chef_resource_id])
    UserPersonalProgram.where(:personal_program_id => @personal_program.id).update_all(:was_updated => true)
    UserPersonalProgram.where(:personal_program_id => @personal_program.id, :state => "none").update_all(:state => "update")
    if params[:condition] == "delete"
      respond_to do |format|
        if @personal_chef_resource.update_attributes(:status => "delete", :priority => nil)
          create_user_remove_resources
          @personal_program.personal_program_chefs.where(personal_chef_resource_id: @personal_chef_resource.id).first.destroy
          format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :success => "Action was successfully changed to delete." } }
          format.json { head :no_content }
        else
          format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :danger => "Action was error when change to delete." } }
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        priority = 0
        if !@personal_program.personal_chef_resources.where(status: "install").last.nil?
          priority = @personal_program.personal_chef_resources.where(status: "install").last.priority
        end
        if @personal_chef_resource.update_attributes(:status => "install", :priority => priority + 1)
          delete_user_remove_resources
          @personal_program.personal_program_chefs.create(personal_chef_resource_id: @personal_chef_resource.id)
          format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :success => "Action was successfully changed to install." } }
          format.json { head :no_content }
        else
          format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :danger => "Action was error when change to install." } }
          format.json { head :no_content }
        end
      end
    end # if params[:chef_id] == "remove"
  end

  # DELETE /personal_program_chefs/1
  # DELETE /personal_program_chefs/1.json
  def destroy
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    @personal_chef_resource = PersonalChefResource.find(params[:personal_chef_resource_id])
    respond_to do |format|
      if @personal_chef_resource.destroy
        UserPersonalProgram.where(:personal_program_id => @personal_program.id).update_all(:was_updated => true)
        UserPersonalProgram.where(:personal_program_id => @personal_program.id, :state => "none").update_all(:state => "update")
        format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :success => "Action was successfully destroy." } }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :danger => "Action was error when destroy." } }
        format.json { head :no_content }
      end
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

    def create_user_remove_resources
      @personal_program.ku_users.each do |user|
        user.user_remove_resources.create(personal_chef_resource_id: @personal_chef_resource.id)
      end
    end

    def delete_user_remove_resources
      UserRemoveResource.where(personal_chef_resource_id: @personal_chef_resource.id, ku_user: @personal_program.ku_users).destroy_all
    end

    def delete_user_remove_resources_for_not_owner
      @personal_program = PersonalProgram.find(params[:personal_program_id])

      respond_to do |format|
        if current_user.user_remove_resources.where(personal_chef_resource_id: params[:personal_chef_resource_id]).destroy
          format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :success => "Action was successfully destroy." } }
          format.json { head :no_content }
        else
          format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :danger => "Action was error when destroy." } }
          format.json { head :no_content }
        end
      end
    end

    def add_remove_resource# mark not use
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
              value = @personal_chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
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
              move_type = @personal_chef_resource.chef_properties.where(:value_type => "move_type").pluck(:value).first
              value = @personal_chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
              value_type = move_type
            when "Bash_script"  # เพื่อลบไฟล์ใน instance (/tmp/xxx กับ /var/lib/tomcat7/webapps/ROOT/bash_script/xxx) และลบไฟล์ใน template ของ cookbook user
              value = @personal_chef_resource.id.to_s
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
