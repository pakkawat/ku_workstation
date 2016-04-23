class PersonalChefResourcesController < ApplicationController
  before_action :set_personal_chef_resource, only: [:show, :edit, :update, :destroy]

  # GET /personal_chef_resources
  # GET /personal_chef_resources.json
  def index
    @personal_chef_resources = PersonalChefResource.all
    @personal_program = PersonalProgram.find(params[:personal_program_id])
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
    @ku_user = current_user
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    @property_count = 0
    case @personal_chef_resource.resource_type
    when "Repository"
      if !@personal_chef_resource.chef_properties.any?
        @personal_chef_resource.chef_properties.build
      end
    when "Download", "Extract", "Deb", "Source", "Move_file", "Execute_command"
      if !@personal_chef_resource.chef_properties.any?
        @personal_chef_resource.chef_properties.build
        @personal_chef_resource.chef_properties.build
      end
    when "Config_file"
      @data = nil
      #@personal_chef_resource.chef_attributes.build
      if !@personal_chef_resource.chef_properties.any?
        @personal_chef_resource.chef_properties.build
      else
        #value = @personal_chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
        if !@personal_chef_resource.chef_file.nil?
          @data = @personal_chef_resource.chef_file.content
        end
      end
    when "Copy_file"
      if !@personal_chef_resource.chef_properties.any?
        @personal_chef_resource.chef_properties.build
        @personal_chef_resource.chef_properties.build
        @personal_chef_resource.chef_properties.build
      end
    when "Create_file"
      @data = nil
      #@personal_chef_resource.chef_attributes.build
      if !@personal_chef_resource.chef_properties.any?
        @personal_chef_resource.chef_properties.build
      else
        if !@personal_program.nil?
          #value = @personal_chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value).first
          if !@personal_chef_resource.chef_file.nil?
            @data = @personal_chef_resource.chef_file.content
          end
        end
      end
    when "Bash_script"
      @data = "#!/bin/bash"
      #@personal_chef_resource.chef_attributes.build
      if !@personal_chef_resource.chef_properties.any?
        @personal_chef_resource.chef_properties.build
        @personal_chef_resource.chef_properties.build
      else
        if !@personal_chef_resource.chef_file.nil?
          @data = @personal_chef_resource.chef_file.content
        end
      end
    end # end case

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
    @ku_user = current_user
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    @property_count = 0
    find_unuse_program_and_file
    respond_to do |format|
      if @personal_chef_resource.update(personal_chef_resource_params)
        format.html { redirect_to edit_personal_program_personal_chef_resource_path(@personal_program, @personal_chef_resource), :flash => { :success => "Action was successfully updated." } }
        format.json { render :show, status: :ok, location: edit_personal_program_personal_chef_resource_path(@personal_program, @personal_chef_resource) }
      else
        format.html { render :edit }
        format.json { render json: @personal_chef_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personal_chef_resources/1
  # DELETE /personal_chef_resources/1.json
  def destroy
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    @personal_chef_resource.destroy
    respond_to do |format|
      format.html { redirect_to personal_program_personal_chef_resources_path(@personal_program), :flash => { :success => "Action was successfully destroyed." } }
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
      params.require(:personal_chef_resource).permit(:resource_type, chef_properties_attributes: [ :id, :value, :value_type ])
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
      case @personal_chef_resource.resource_type
      when "Repository" # delete program when program_name diff
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              diff_program_name = find_diff_program_name(chef_property.value, value[:value])
              add_remove_resource(diff_program_name, "program")
            end
          end
        end
      when "Deb" # delete program when source file change
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            if value[:value_type] == "source_file"
              chef_property = ChefProperty.find(value[:id])
              if chef_property.value != value[:value]
                value = @personal_chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
                add_remove_resource(value, "program")
              end
            end
          end
        end
      when "Source" # delete program when source file change
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            if value[:value_type] == "source_file"
              chef_property = ChefProperty.find(value[:id])
              if chef_property.value != value[:value]
                value = @personal_chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
                add_remove_resource(value, "program")
              end
            end
          end
        end
      when "Download" # delete download file when url OR!!!! source file change
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              value = @personal_chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
              add_remove_resource(value, "file")
            end
          end
        end
      when "Extract" # change source_file or change extract_to or delete resource: delete extract_to folder
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              value = @personal_chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value).first
              add_remove_resource(value, "folder")
            end
          end
        end
      when "Config_file" # delete file when config_file(path+filename) change
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              #value = @chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
              add_remove_resource(chef_property.value, "file")
              @personal_chef_resource.chef_file.destroy
            else
              save_file_content(params[:config_file_value])
            end
          end
        end
      when "Copy_file" # delete destination when copy_type or source_file or destination_file change
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              value = @personal_chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
              copy_type = @personal_chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value).first
              add_remove_resource(value, copy_type)
            end
          end
        end
      when "Create_file" # delete file when created_file(path+filename) change
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              add_remove_resource(chef_property.value, "file") # delete old file
              #create_file(params[:created_file_content], value[:value]) # create new file
              save_file_content(params[:created_file_content])
            else
              #create_file(params[:created_file_content], chef_property.value) # old file then update content
              save_file_content(params[:created_file_content])
            end
          else
            #create_file(params[:created_file_content], value[:value]) # new file
            save_file_content(params[:created_file_content])
          end
        end
      when "Move_file" # delete destination file when source file or destination change
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            chef_property = ChefProperty.find(value[:id])
            if chef_property.value != value[:value]
              source_file = @personal_chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
              destination_file = @personal_chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
              src_file_extname = File.extname(source_file)
              if src_file_extname == ""
                add_remove_resource(destination_file, "folder")
              else
                add_remove_resource(destination_file, "file")
              end
            end
          end
        end
      when "Bash_script"
        params[:personal_chef_resource][:chef_properties_attributes].each do |key, value|
          if !value[:id].nil? # old_value
            if value[:value_type] == "bash_script"
              #create_bash_script_file(@personal_chef_resource.id.to_s, params[:bash_script_content])
              save_file_content(params[:bash_script_content])
              #bash = BashScript.find(value[:value])
              # check diff between bash.bash_script_content and params[:bash_script_content] then delete text file
              #bash.update_attribute(:bash_script_content, params[:bash_script_content])
            end
          else
            if value[:value_type] == "bash_script"
              #create_bash_script_file(@personal_chef_resource.id.to_s, params[:bash_script_content])
              save_file_content(params[:bash_script_content])
              value[:value] = "_" + @personal_chef_resource.id.to_s
              #bash = BashScript.new(bash_script_content: params[:bash_script_content])
              #bash.save
              #value[:value] = bash.id
            end
          end
        end
      end # end case

    end

    def add_remove_resource(value, value_type)
      if @personal_chef_resource.resource_type == "Repository" # repo not check chef_resource_id because install from repo will have one or more program
        @personal_chef_resource.personal_programs.each do |personal_program|
          personal_program.ku_users.each do |user|
            user.user_remove_resources.create(personal_program_id: personal_program.id, personal_chef_resource_id: @personal_chef_resource.id, resource_type: @personal_chef_resource.resource_type, value: value, value_type: value_type)
          end
        end
      else
        @personal_chef_resource.personal_programs.each do |personal_program|
          personal_program.ku_users.each do |user|
            if !user.user_remove_resources.find_by(personal_chef_resource_id: @personal_chef_resource.id).present? # check Is chef_resource_id alredy in remove_resources
              user.user_remove_resources.create(personal_program_id: personal_program.id, personal_chef_resource_id: @personal_chef_resource.id, resource_type: @personal_chef_resource.resource_type, value: value, value_type: value_type)
            end
          end
        end
      end
    end

    def find_diff_program_name(resource1, resource2)
      array1 = resource1.split(' ')
      array2 = resource2.split(' ')
      return (array1 - array2).join(" ")
    end

    def save_file_content(file_content)
      if !@personal_chef_resource.chef_file.nil?
        @personal_chef_resource.chef_file.update_attribute(:content, file_content)
      else
        if @personal_chef_resource.resource_type != "Config_file" # chef_file ของ config_file จะถูกสร้างก็ต่อเมื่อ file ได้ถูก donwload ครั้งแรกที่ personal_program edit
          chef_file = ChefFile.new(content: file_content)
          chef_file.save
          @personal_chef_resource.chef_file.create(chef_file: chef_file)
        end
      end
    end

    def create_file(created_file_content, value)
      file_name = File.basename(value)
      @personal_program.ku_users.each do |user|
        file_full_path = "/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/templates/" + file_name + ".erb"
        File.open(file_full_path, "w") do |f|
          f.write(created_file_content)
        end
      end
    end

    def create_bash_script_file(personal_chef_resource_id, bash_script_content)
      @personal_program.ku_users.each do |user|
        file_full_path = "/home/ubuntu/chef-repo/cookbooks/" + user.ku_id + "/templates/" + user.id.to_s + "_" + personal_chef_resource_id + ".sh.erb"
        File.open(file_full_path, "w") do |f|
          f.write(bash_script_content)
        end
      end
    end

end
