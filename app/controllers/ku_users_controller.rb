class KuUsersController < ApplicationController
  include UserResourceGenerator
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  def index
    @kuusers = KuUser.all
  end

  def show
    @kuuser = KuUser.find(params[:id])
    @result = Delayed::Job.where(owner: @kuuser.id)
    if @result.any?
      @user_job =  @result.first
      @job_error = !@user_job.last_error.nil?
    end
    ###############      For Test      #####################
    require 'open3'
    captured_stdout = ''
    captured_stderr = ''
    exit_status = Open3.popen3(ENV, "knife node show " + @kuuser.ku_id + " -r -c /home/ubuntu/chef-repo/.chef/knife.rb") {|stdin, stdout, stderr, wait_thr|
      pid = wait_thr.pid # pid of the started process.
      stdin.close
      captured_stdout = stdout.read
      captured_stderr = stderr.read
      wait_thr.value # Process::Status object returned.
    }
    @actual_run_list = captured_stdout
    ##########################################################
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

  def delete_personal_program_from_user
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
    @user_job = Delayed::Job.where(owner: params[:job_id]).first

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
    def correct_user
      @user = KuUser.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end



end
