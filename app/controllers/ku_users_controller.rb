class KuUsersController < ApplicationController
  include UserResourceGenerator
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user_or_admin,   only: [:show, :edit, :update, :create_personal_program, :delete_personal_program, :add_personal_program, :apply_change, :delete_user_job]
  before_action :admin_user,     only: :destroy
  def index
    @kuusers = KuUser.all
  end

  def show
    require 'chef'

    @kuuser = KuUser.find(params[:id])
    @result = Delayed::Job.where(owner: @kuuser.id)
    if @result.any?
      @user_job =  @result.first
      @job_error = !@user_job.last_error.nil?
    end

    Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
    query = Chef::Search::Query.new
    nodes = query.search('node', 'name:' + @kuuser.ku_id).first rescue []
    @node = nodes.first

    @was_updated = @kuuser.user_personal_programs.where(was_updated: true).count

    @my_personal_programs = @kuuser.personal_programs.where("user_personal_programs.status = 'install'")
    @all_personal_programs = PersonalProgram.where.not(id: @my_personal_programs)

  end

  def new
    @kuuser = KuUser.new
  end

  def create
    @kuuser = KuUser.new(ku_user_params)
    #render plain: ku_user_params.inspect
    #@KuUser.save
    if @kuuser.save
      #create_ec2_instance
      #log_in @kuuser
      #redirect_to ku_users_path, :notice => "Welcome "

      output = File.open("#{Rails.root}/log/knife/#{@kuuser.ku_id}.log","w")
      output << ""
      output.close
      @kuuser.create_log(:log_path => "#{Rails.root}/log/knife/#{@kuuser.ku_id}.log", :error => false)
      @job = Delayed::Job.enqueue KuUserJob.new(@kuuser.id,"create",ku_user_params[:password])
      str_des = "Create instance:"+@kuuser.ku_id
      @job.update_column(:description, str_des)
      @job.update_column(:owner, 0)
      flash[:success] = str_des+" with Job ID:"+@job.id.to_s

      redirect_to ku_users_path

      #render plain: @kuuser.inspect+"--------------"+"#{Rails.root}/log/knife/#{@kuuser.ku_id}.log"
    else
      render "new"
    end
  end

  def edit
    @kuuser = KuUser.find(params[:id])
  end

  def update
    @kuuser = KuUser.find(params[:id])

    if @kuuser.update_attributes(ku_user_params)
      flash[:success] = "User has been updated"
      redirect_to @kuuser
    else
      render "edit"
    end
  end

  def destroy
    @kuuser = KuUser.find(params[:id])
    @job = Delayed::Job.enqueue KuUserJob.new(@kuuser.id,"delete","")

    str_des = "Delete instance:"+@kuuser.ku_id
    @job.update_column(:description, str_des)
    @job.update_column(:owner, 0)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s

    #@kuuser.find(params[:id]).destroy
    #flash[:success] = "User deleted"
    redirect_to ku_users_path
  end

  def edit_attribute
    @kuuser = KuUser.find(params[:id])
    @program = Program.find(params[:program_id])
    #render plain: @kuuser.inspect
    chef_attributes = ChefAttribute.where(chef_resource_id: @program.chef_resources.select("id"))
    @chef_values = ChefValue.where(chef_attribute_id: chef_attributes, ku_user_id: @kuuser)
  end

  def update_attribute
    #@kuuser = KuUser.find(params[:id])
    #@program = Program.find(params[:program_id])
    #render plain: @kuuser.inspect
    #raise "test"
    params[:ku_user][:chef_value].each do |key, value|
      chef_value = ChefValue.find(key)
      chef_value.update_attribute(:value,value[:value])
      #str += "id:"+chef_value.id.to_s+" att_id:"+chef_value.chef_attribute_id.to_s+" value:"+value[:value]+"---"
    end
    flash[:success] = "Config has been updated"
    redirect_to edit_ku_user_attribute_path(id: params[:id], program_id: params[:program_id])
  end

  def apply_change
    @kuuser = KuUser.find(params[:id])
    @job = Delayed::Job.enqueue KuUserJob.new(@kuuser.id,"apply_change","")

    str_des = "Apply change on:"+@kuuser.ku_id
    @job.update_column(:description, str_des)
    @job.update_column(:owner, @kuuser.id)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s

    redirect_to @kuuser
  end

  def apply_change2
    @kuuser = KuUser.find(params[:id])
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @kuuser.ku_id + "/recipes/user_personal_program_list.rb", 'w') do |f|
      @kuuser.personal_programs.each do |personal_program|
        f.write("include_attribute '#{@kuuser.ku_id}::#{personal_program.program_name}'")
      end
    end

    @kuuser.personal_programs.where("user_personal_programs.status = 'install'").each do |personal_program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + @kuuser.ku_id + "/recipes/#{personal_program.program_name}.rb", 'w') do |f|
        personal_program.personal_chef_resources.each do |personal_chef_resource|
          f.write(UserResourceGenerator.install_resource(personal_chef_resource, @kuuser))
        end
      end
    end

    @kuuser.personal_programs.where("user_personal_programs.status = 'uninstall'").each do |personal_program|
      File.open("/home/ubuntu/chef-repo/cookbooks/" + @kuuser.ku_id + "/recipes/#{personal_program.program_name}.rb", 'w') do |f|
        personal_program.personal_chef_resources.each do |personal_chef_resource|
          f.write(UserResourceGenerator.uninstall_resource(personal_chef_resource, @kuuser))
        end
      end
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + @kuuser.ku_id + "/recipes/user_remove_disuse_resources.rb", 'w') do |f|
      @kuuser.user_remove_resources.each do |remove_resource|
        f.write(UserResourceGenerator.remove_disuse_resource(remove_resource, @kuuser))
      end
    end

    flash[:success] = "Apply change"
    redirect_to @kuuser
  end

  def delete_personal_program_from_user # mark not use
    @kuuser = KuUser.find(params[:id])
    @user_personal_program = UserPersonalProgram.find(params[:user_personal_program_id])
    @personal_program = PersonalProgram.find(@user_personal_program.personal_program_id)

    respond_to do |format|
      if @user_personal_program.update_attribute(:status, "uninstall")
        format.html { redirect_to @kuuser, :flash => { :success => @personal_program.program_name + " was successfully deleted." } }
        format.json { render :show, status: :created, location: @kuuser }
      else
        format.html { redirect_to @kuuser }
        format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_user_job
    @kuuser = KuUser.find(params[:id])
    @user_job = Delayed::Job.where(id: params[:job_id]).first

    respond_to do |format|
      if @user_job.destroy
        format.html { redirect_to @kuuser, :flash => { :success => "Job was successfully deleted." } }
        format.json { render :show, status: :created, location: @kuuser }
      else
        format.html { redirect_to @kuuser }
        format.json { render json: @user_job.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_personal_program
    #str_temp = params[:program_name] + "---" + params[:note]
    #render plain: str_temp.inspect
    @kuuser = KuUser.find(params[:id])
    if params[:program_name] != ""
      personal_program = PersonalProgram.new(program_name: params[:program_name], note: params[:note], owner: @kuuser.id)
      respond_to do |format|
        if personal_program.save
          @kuuser.user_personal_programs.create(personal_program: personal_program, status: "install")
          format.html { redirect_to @kuuser, :flash => { :success => personal_program.program_name + " was successfully created." } }
          format.json { render :show, status: :created, location: @kuuser }
        else
          format.html { redirect_to @kuuser, :flash => { :danger => "Create personal program error." } }
        end
      end
    else
      flash[:danger] = "Program name cannot be null or empty."
      redirect_to @kuuser
    end
  end

  def delete_personal_program
    @kuuser = KuUser.find(params[:id])
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    user_personal_program = @kuuser.user_personal_programs.find_by(personal_program_id: @personal_program).id
    respond_to do |format|
      if user_personal_program.update(status: "uninstall", was_updated: true)
        format.html { redirect_to @kuuser, :flash => { :success => @personal_program.program_name + " was successfully deleted." } }
        #format.json { render :show, status: :created, location: @kuuser }
      else
        format.html { redirect_to @kuuser, :flash => { :danger => "Error delete " + @personal_program.program_name + "." } }
        #format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_personal_program
    @kuuser = KuUser.find(params[:id])
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    user_personal_program = @kuuser.user_personal_programs.find_by(personal_program_id: @personal_program)
    if user_personal_program.present?
      respond_to do |format|
        if user_personal_program.update(status: "install", was_updated: true)
          format.html { redirect_to personal_programs_path, :flash => { :success => @personal_program.program_name + " was successfully added." } }
          #format.json { render :show, status: :created, location: personal_programs_path }
        else
          format.html { redirect_to personal_programs_path }
          #format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @ku_user.user_personal_programs.create(personal_program: @personal_program, status: "install")
          format.html { redirect_to personal_programs_path, :flash => { :success => @personal_program.program_name + " was successfully added." } }
          #format.json { render :show, status: :created, location: personal_programs_path }
        else
          format.html { redirect_to personal_programs_path }
          #format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private
    def ku_user_params
      params.require(:ku_user).permit(:ku_id, :username, :password, :password_confirmation, :firstname, :lastname, :sex, :email, :degree_level, :faculty, :major_field, :status, :campus, chef_value: [ :id, :chef_attribute_id, :value ])
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user_or_admin
      @user = KuUser.find(params[:id])
      redirect_to(current_user) unless current_user?(@user) || current_user.admin?
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end



end
