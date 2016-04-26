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
    when "Download", "Extract", "Deb", "Source", "Execute_command"
      if !@chef_resource.chef_properties.any?
        @chef_resource.chef_properties.build
        @chef_resource.chef_properties.build
      end
    when "Config_file"
      @data = nil
      @chef_resource.chef_attributes.build
      if !@chef_resource.chef_properties.any?
        @chef_resource.chef_properties.build
      else
        if !@program.nil?
          value = @chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
          if !value.empty?
          file_name = File.basename(value)
            if File.exists?("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb")
              @data = File.read("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb")
            end
          end
        end
      end
    when "Copy_file", "Move_file"
      if !@chef_resource.chef_properties.any?
        @chef_resource.chef_properties.build
        @chef_resource.chef_properties.build
        @chef_resource.chef_properties.build
      end
    when "Create_file"
      @data = nil
      @chef_resource.chef_attributes.build
      if !@chef_resource.chef_properties.any?
        @chef_resource.chef_properties.build
      else
        if !@program.nil?
          value = @chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value).first
          if !value.empty?
          file_name = File.basename(value)
            if File.exists?("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb")
              @data = File.read("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb")
            end
          end
        end
      end
    when "Bash_script"
      @data = "#!/bin/bash"
      @chef_resource.chef_attributes.build
      if !@chef_resource.chef_properties.any?
        @chef_resource.chef_properties.build
        @chef_resource.chef_properties.build
      else
        if !@program.nil?
          if File.exists?("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + @program.id.to_s + "_" + @chef_resource.id.to_s + ".sh.erb")
            @data = File.read("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + @program.id.to_s + "_" + @chef_resource.id.to_s + ".sh.erb")
          end
        end
      end
    end # end case

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
    find_unuse_program_and_file
    respond_to do |format|
      if @chef_resource.update(chef_resource_params)
        #create_chef_value
        if !@program.nil?
          format.html { redirect_to edit_program_chef_resource_path(program_id: @program.id, id: @chef_resource.id), :flash => { :success => "Action was successfully updated." } }
        else
          format.html { redirect_to edit_chef_resource_path(@chef_resource), :flash => { :success => "Action was successfully updated." } }
        end
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
      format.html { redirect_to chef_resources_url, notice: 'Action was successfully destroyed.' }
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
      params.require(:chef_resource).permit(:resource_type, chef_properties_attributes: [ :id, :value, :value_type ], chef_attributes_attributes: [ :id, :name, :value, :_destroy ])
    end



    #1. repo
    #change program_name or delete resource: delete program

    #2. deb
    #change source_file or delete resource: delete program

    #3. install from source
    #change source_file or delete resource: delete program

    #4. download file
    #change source_file or change url or delete resource: delete source_file

    #5. extract
    #change source_file or change extract_to or delete resource: delete extract_to folder

    def find_unuse_program_and_file
      case @chef_resource.resource_type
      when "Repository" # delete program when program_name diff
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              diff_program_name = find_diff_program_name(chef_property.value, value[:value])
              add_remove_resource(diff_program_name, "program")
            end
          end
        end
      when "Deb" # delete program when source file change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            if value[:value_type] == "source_file"
              chef_property = ChefProperty.find(value[:id])
              if chef_property.value != value[:value]
                value = @chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
                add_remove_resource(value, "program")
              end
            end
          end
        end
      when "Source" # delete program when source file change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            if value[:value_type] == "source_file"
              chef_property = ChefProperty.find(value[:id])
              if chef_property.value != value[:value]
                value = @chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
                add_remove_resource(value, "program")
              end
            end
          end
        end
      when "Download" # delete download file when url OR!!!! source file change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              value = @chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
              add_remove_resource(value, "file")
            end
          end
        end
      when "Extract" # change source_file or change extract_to or delete resource: delete extract_to folder
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              value = @chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value).first
              add_remove_resource(value, "folder")
            end
          end
        end
      when "Config_file" # delete file when config_file(path+filename) change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              #value = @chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
              add_remove_resource(chef_property.value, "file")
            else
              save_config_file(params[:config_file_value])
            end
          end
        end
      when "Copy_file" # delete destination when copy_type or source_file or destination_file change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              value = @chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
              copy_type = @chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value).first
              add_remove_resource(value, copy_type)
            end
          end
        end
      when "Create_file" # delete file when created_file(path+filename) change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              add_remove_resource(chef_property.value, "file") # delete old file
              create_file(params[:created_file_content], value[:value]) # create new file
            else
              create_file(params[:created_file_content], chef_property.value) # old file then update content
            end
          else
            create_file(params[:created_file_content], value[:value]) # new file
          end
        end
      when "Move_file" # delete destination file when source file or destination change
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              move_type = @chef_resource.chef_properties.where(:value_type => "move_type").pluck(:value).first
              destination_file = @chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
              add_remove_resource(destination_file, move_type)
            end
          end
        end
      when "Bash_script"
        params[:chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            if value[:value_type] == "bash_script"
              create_bash_script_file( @program.id.to_s + "_" + @chef_resource.id.to_s, params[:bash_script_content])
              #bash = BashScript.find(value[:value])
              # check diff between bash.bash_script_content and params[:bash_script_content] then delete text file
              #bash.update_attribute(:bash_script_content, params[:bash_script_content])
            end
          else
            if value[:value_type] == "bash_script"
              create_bash_script_file( @program.id.to_s + "_" + @chef_resource.id.to_s, params[:bash_script_content])
              value[:value] = @program.id.to_s + "_" + @chef_resource.id.to_s
              #bash = BashScript.new(bash_script_content: params[:bash_script_content])
              #bash.save
              #value[:value] = bash.id
            end
          end
        end
      end # end case

    end

    def add_remove_resource(value, value_type)
      if @chef_resource.resource_type == "Repository" # repo not check chef_resource_id because install from repo will have one or more program
        @chef_resource.programs.each do |program|
          remove_resource = RemoveResource.new(program_id: program.id, chef_resource_id: @chef_resource.id, resource_type: @chef_resource.resource_type, value: value, value_type: value_type)
          remove_resource.save
        end
      else
        @chef_resource.programs.each do |program|
          if !program.remove_resources.find_by(chef_resource_id: @chef_resource.id).present? # check Is chef_resource_id alredy in remove_resources
            remove_resource = RemoveResource.new(program_id: program.id, chef_resource_id: @chef_resource.id, resource_type: @chef_resource.resource_type, value: value, value_type: value_type)
            remove_resource.save
          end
        end
      end
    end

    def find_diff_program_name(resource1, resource2)
      array1 = resource1.split(' ')
      array2 = resource2.split(' ')
      return (array1 - array2).join(" ")
    end

    def save_config_file(config_file_value)
      if !@program.nil?
        value = @chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
        file_name = File.basename(value)
        file_full_path = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb"
        if File.exists?(file_full_path)
          File.open(file_full_path, "w") do |f|
            f.write(config_file_value)
          end
        end
      end
    end

    def create_file(created_file_content, value)
      if !@program.nil?
        file_name = File.basename(value)
        file_full_path = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb"
        File.open(file_full_path, "w") do |f|
          f.write(created_file_content)
        end
      end
    end

    def create_chef_value # mark not use
      if !@program.nil?
        chef_attributes = ChefAttribute.where(chef_resource_id: @program.chef_resources.pluck("id"))
        users = UsersProgram.where(program_id: @program.id).pluck("ku_user_id")
        users.each do |user|
          chef_attributes.each do |chef_attribute|
            ChefValue.where(chef_attribute_id: chef_attribute, ku_user_id: user).first_or_create
          end
        end
      end
    end # end def

    def create_bash_script_file(file_name, bash_script_content)
      if !@program.nil?
        file_full_path = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".sh.erb"
        File.open(file_full_path, "w") do |f|
          f.write(bash_script_content)
        end
      end
    end

end
