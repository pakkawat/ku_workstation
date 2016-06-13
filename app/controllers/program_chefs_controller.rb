class ProgramChefsController < ApplicationController
  #before_action :set_program_chef, only: [:show, :edit, :update, :destroy]

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
    #@program_chef = ProgramChef.new
  end

  # GET /program_chefs/1/edit
  def edit
  end

  # POST /program_chefs
  # POST /program_chefs.json
  def create
    #@program_chef = ProgramChef.new(program_chef_params)
    @program = Program.find(params[:program_id])
    @chef_resource = ChefResource.new(resource_type: params[:chef_resource_type])

    respond_to do |format|
      if @program.program_chefs.create(chef_resource: @chef_resource)
        ProgramsSubject.where(:program_id => @program.id).update_all(:was_updated => true)
        ProgramsSubject.where(:program_id => @program.id, :state => "none").update_all(:state => "update")
        format.html { redirect_to edit_program_path(@program), :flash => { :success => "Action was successfully created." } }
        format.json { render :show, status: :created, location: edit_program_path(@program) }
      else
        format.html { render :new }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /program_chefs/1
  # PATCH/PUT /program_chefs/1.json
  def update
    @program = Program.find(params[:program_id])
    @chef_resource = ChefResource.find(params[:chef_id])
    if params[:condition] == "delete"
      respond_to do |format|
        if @chef_resource.update_attribute(:status, "delete")
          ProgramsSubject.where(:program_id => @program.id).update_all(:was_updated => true)
          ProgramsSubject.where(:program_id => @program.id, :state => "none").update_all(:state => "update")
          format.html { redirect_to edit_program_path(@program), :flash => { :success => "Action was successfully changed to delete." } }
          format.json { head :no_content }
        else
          format.html { redirect_to edit_program_path(@program), :flash => { :danger => "Action was error when change to delete." } }
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        if @chef_resource.update_attribute(:status, "install")
          ProgramsSubject.where(:program_id => @program.id).update_all(:was_updated => true)
          ProgramsSubject.where(:program_id => @program.id, :state => "none").update_all(:state => "update")
          format.html { redirect_to edit_program_path(@program), :flash => { :success => "Action was successfully changed to install." } }
          format.json { head :no_content }
        else
          format.html { redirect_to edit_program_path(@program), :flash => { :danger => "Action was error when change to install." } }
          format.json { head :no_content }
        end
      end
    end # if params[:chef_id] == "remove"
  end

  # DELETE /program_chefs/1
  # DELETE /program_chefs/1.json
  def destroy
    @program = Program.find(params[:program_id])
    @chef_resource = ChefResource.find(params[:chef_id])
    #add_remove_resource
    #@program.program_chefs.find_by(chef_resource_id: @chef_resource.id).destroy
    #@program_chef.destroy
    respond_to do |format|
      if @chef_resource.destroy
        ProgramsSubject.where(:program_id => @program.id).update_all(:was_updated => true)
        ProgramsSubject.where(:program_id => @program.id, :state => "none").update_all(:state => "update")
        format.html { redirect_to edit_program_path(@program), :flash => { :success => "Action was successfully destroy." } }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_program_path(@program), :flash => { :danger => "Action was error when destroy." } }
        format.json { head :no_content }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  #def set_program_chef
    #@program_chef = ProgramChef.find(params[:id])
  #end

  # Never trust parameters from the scary internet, only allow the white list through.
  #def program_chef_params
    #params[:program_chef]
  #end

  def add_remove_resource # mark not use
    if @chef_resource.resource_type == "Repository" # repo not check chef_resource_id because install from repo will have one or more program
      value = @chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
      remove_resource = RemoveResource.new(program_id: @program.id, chef_resource_id: @chef_resource.id, resource_type: @chef_resource.resource_type, value: value, value_type: "program")
      remove_resource.save
    else
      if !@program.remove_resources.find_by(chef_resource_id: @chef_resource.id).present? # check Is chef_resource_id alredy in remove_resources
        value = nil
        value_type = nil
        case @chef_resource.resource_type
        when "Deb"
          value = @chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
          value_type = "program"
        when "Source"
          value = @chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
          value_type = "program"
        when "Download"
          value = @chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
          value_type = "file"
        when "Extract"
          value = @chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value).first
          value_type = "folder"
        when "Config_file"
          delete_chef_attributes
          value = @chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
          #delete_config_file_in_templates(value)
          value_type = "file"
        when "Copy_file"
          value = @chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
          value_type = @chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value).first
        when "Create_file"
          delete_chef_attributes
          value = @chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value).first
          #delete_file_in_templates(value)
          value_type = "file"
        when "Move_file"
          move_type = @chef_resource.chef_properties.where(:value_type => "move_type").pluck(:value).first
          value = @chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
          value_type = move_type
        when "Bash_script" # เพื่อลบไฟล์ใน instance (/tmp/xxx กับ /var/lib/tomcat7/webapps/ROOT/bash_script/xxx) และลบไฟล์ใน template ของ cookbook program
          value = @chef_resource.id.to_s
          value_type = "file"
          delete_chef_attributes
        when "Execute_command"
          value = @chef_resource.chef_properties.where(:value_type => "execute_command").pluck(:value).first
          value_type = "command"
        end
        remove_resource = RemoveResource.new(program_id: @program.id, chef_resource_id: @chef_resource.id, resource_type: @chef_resource.resource_type, value: value, value_type: value_type)
        remove_resource.save
      end
    end
  end

  def delete_config_file_in_templates(value)
    file_name = File.basename(value)

		path_to_file = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb"
		File.delete(path_to_file) if File.exist?(path_to_file)
  end

  def delete_chef_attributes
    @chef_resource.chef_attributes.destroy_all
  end

  def delete_file_in_templates(value)
    src_file_name = File.basename(value)

    path_to_file = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb"
		File.delete(path_to_file) if File.exist?(path_to_file)
  end

end
