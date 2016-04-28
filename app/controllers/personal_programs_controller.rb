class PersonalProgramsController < ApplicationController
  before_action :set_personal_program, only: [:show, :edit, :update, :destroy]
  before_action :owner_program, only: [:update, :destroy]

  # GET /personal_programs
  # GET /personal_programs.json
  def index
    @ku_user = current_user
    @my_personal_programs = @ku_user.personal_programs.where("user_personal_programs.status = 'install'")
    @all_personal_programs = PersonalProgram.where.not(id: @my_personal_programs)
  end

  # GET /personal_programs/1
  # GET /personal_programs/1.json
  def show
  end

  # GET /personal_programs/new
  def new
    @personal_program = PersonalProgram.new
  end

  # GET /personal_programs/1/edit
  def edit
    @ku_user = current_user
    check_config_file
    #@personal_program = PersonalProgram.find(params[:id])
  end

  # POST /personal_programs
  # POST /personal_programs.json
  def create
    @personal_program = PersonalProgram.new(personal_program_params)

    respond_to do |format|
      if @personal_program.save
        @personal_program.update_attribute(:owner, current_user.id)
        format.html { redirect_to personal_programs_path, :flash => { :success => @personal_program.program_name + ' was successfully created.' } }
        format.json { render :show, status: :created, location: @personal_program }
      else
        format.html { render :new }
        format.json { render json: @personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personal_programs/1
  # PATCH/PUT /personal_programs/1.json
  def update
    respond_to do |format|
      if @personal_program.update(personal_program_params)
        format.html { redirect_to edit_personal_program_path(@personal_program), :flash => { :success => @personal_program.program_name + ' was successfully updated.' } }
        format.json { render :show, status: :ok, location: @personal_program }
      else
        format.html { render :edit }
        format.json { render json: @personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personal_programs/1
  # DELETE /personal_programs/1.json
  def destroy
    @personal_program.destroy
    respond_to do |format|
      format.html { redirect_to personal_programs_url, :flash => { :success => 'Personal program was successfully destroyed.' } }
      format.json { head :no_content }
    end
  end

    def sort
      personal_program = PersonalProgram.find(params[:personal_program_id])
      params[:order].each do |key,value|
        personal_program.personal_chef_resources.find_by(id: value[:id]).update_attribute(:priority,value[:position])
      end
      render :nothing => true
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personal_program
      @personal_program = PersonalProgram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def personal_program_params
      params.require(:personal_program).permit(:program_name, :note)
    end

    def check_config_file
      personal_chef_resources = @personal_program.personal_chef_resources.where(:resource_type => "Config_file")
      if personal_chef_resources.any?
        personal_chef_resources.each do |personal_chef_resource|
          value = personal_chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
          if !value.nil?
            if personal_chef_resource.chef_file.nil?
              file_name = File.basename(value)
              donwload_config_file(file_name, personal_chef_resource)
            end
          end
        end
      end
    end

    def donwload_config_file(file_name, personal_chef_resource)
      require 'chef'
      require 'open-uri'
      error = false
      #ku_id = KuUser.where(id: UsersProgram.where(:program_id => @program.id).uniq.pluck(:ku_user_id)).pluck(:ku_id).first
      Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
      query = Chef::Search::Query.new
      nodes = query.search('node', 'name:' + @ku_user.ku_id).first rescue []
      node = nodes.first
      begin
        download = open("http://" + node.ec2.public_hostname + ":8080/sharedfile/" + file_name)
      rescue
        error = true
      end
      if !error
        #IO.copy_stream(download, file_full_path)
        personal_chef_resource.create_chef_file(content: download.read)
      end
    end

    def owner_program
      redirect_to(current_user) unless @personal_program.owner == current_user.id
    end

end
