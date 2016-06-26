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

    if !@node.nil?
      get_ec2_instance_information
    else
      @ec2_cost = nil
      @instance_state = nil
      @public_dns_name = nil
    end

    @was_updated = @kuuser.user_personal_programs.where.not(state: "none").count

    #@my_personal_programs = @kuuser.personal_programs.where("user_personal_programs.status = 'install'")
    @all_personal_programs = PersonalProgram.where.not(id: @kuuser.personal_programs)

    @user_programs = Program.where(id: ProgramsSubject.where(subject_id: @kuuser.subjects.where("user_subjects.user_enabled = true").pluck(:id), program_enabled: true).pluck(:program_id))

    @user_error = @kuuser.user_errors.first
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
      @kuuser.create_instance(:uptime_seconds => 0, :network_tx => 0)
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
      flash[:success] = "User was successfully updated"
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

  def update_attribute
    @kuuser = KuUser.find(params[:id])
    #@program = Program.find(params[:program_id])
    #render plain: @kuuser.inspect
    #raise "test"
    params[:ku_user][:chef_value].each do |key, value|
      chef_value = ChefValue.find(key)
      chef_value.update_attribute(:value,value[:value])
      #str += "id:"+chef_value.id.to_s+" att_id:"+chef_value.chef_attribute_id.to_s+" value:"+value[:value]+"---"
    end
    flash[:success] = "Config was successfully updated"
    redirect_to @kuuser
    #redirect_to edit_ku_user_attribute_path(id: params[:id], program_id: params[:program_id])
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

    @kuuser.user_personal_programs.where(status: 'uninstall').destroy_all
    @kuuser.user_personal_programs.update_all(:installed => true, :status => "none",:was_updated => false, :state => "none")
    @kuuser.user_remove_resources.destroy_all

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
          @kuuser.user_personal_programs.create(personal_program: personal_program, status: "install", state: "install")
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
    user_personal_program = @kuuser.user_personal_programs.find_by(personal_program_id: @personal_program)
    if user_personal_program.installed # true
      respond_to do |format|
        if user_personal_program.update(status: "uninstall", state: "uninstall")
          format.html { redirect_to @kuuser, :flash => { :success => @personal_program.program_name + " has changed state to uninstall" } }
          #format.json { render :show, status: :created, location: @kuuser }
        else
          format.html { redirect_to @kuuser, :flash => { :danger => "Error delete " + @personal_program.program_name + "." } }
          #format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if user_personal_program.destroy
          format.html { redirect_to @kuuser, :flash => { :success => @personal_program.program_name + " was successfully deleted." } }
          #format.json { render :show, status: :created, location: @kuuser }
        else
          format.html { redirect_to @kuuser, :flash => { :danger => "Error delete " + @personal_program.program_name + "." } }
          #format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  def add_personal_program
    @kuuser = KuUser.find(params[:id])
    @personal_program = PersonalProgram.find(params[:personal_program_id])
    state = ""
    user_personal_program = @kuuser.user_personal_programs.find_by(personal_program_id: @personal_program)
    if user_personal_program.present?
      respond_to do |format|
        check_error = true
        if user_personal_program.was_updated
          check_error = user_personal_program.update(status: "install", state: "update")
          state = "update"
        else
          check_error = user_personal_program.update(status: "install", state: "none")
          state = "normal"
        end
        if check_error
          format.html { redirect_to @kuuser, :flash => { :success => @personal_program.program_name + " has changed state to " + state } }
          #format.json { render :show, status: :created, location: personal_programs_path }
        else
          format.html { redirect_to @kuuser, :flash => { :danger => "Error add " + @personal_program.program_name + "." } }
          #format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @kuuser.user_personal_programs.create(personal_program: @personal_program, status: "install", state: "install")
          format.html { redirect_to @kuuser, :flash => { :success => @personal_program.program_name + " has changed state to install" } }
          #format.json { render :show, status: :created, location: personal_programs_path }
        else
          format.html { redirect_to @kuuser, :flash => { :danger => "Error add " + @personal_program.program_name + "." } }
          #format.json { render json: @user_personal_program.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def start_instance
    require 'chef'
    require 'aws-sdk'

    @kuuser = KuUser.find(params[:id])

    Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
    query = Chef::Search::Query.new
    nodes = query.search('node', 'name:' + @kuuser.ku_id).first rescue []
    @node = nodes.first

    ec2 = Aws::EC2::Client.new
    ec2.start_instances(instance_ids:[@node.ec2.instance_id])

    flash[:success] = @kuuser.ku_id + ' instance was successfully started.'
    redirect_to @kuuser

  end

  def stop_instance
    require 'chef'
    require 'aws-sdk'

    @kuuser = KuUser.find(params[:id])

    Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
    query = Chef::Search::Query.new
    nodes = query.search('node', 'name:' + @kuuser.ku_id).first rescue []
    @node = nodes.first

    respond_to do |format|
      if @kuuser.instance.update_attributes(:uptime_seconds => @kuuser.instance.uptime_seconds + @node.uptime_seconds,
                                            :network_tx => @kuuser.instance.network_tx + @node.counters.network.interfaces.eth0.tx.bytes.to_i)
        ec2 = Aws::EC2::Client.new
        ec2.stop_instances(instance_ids:[@node.ec2.instance_id])
        format.html { redirect_to @kuuser, :flash => { :success => @kuuser.ku_id + ' instance was successfully stopped.' } }
      else
        format.html { redirect_to @kuuser, :flash => { :danger => "Error stop instance " + @kuuser.ku_id + "." } }
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

    def calculate_ec2_cost(uptime_seconds, network_tx_bytes)
      return instance_running_cost(uptime_seconds) + data_tranfer_calculate_cost(network_tx_bytes)
    end

    def instance_running_cost(uptime_seconds)
      require 'awscosts'
      time_to_int = uptime_seconds.to_i
      region = AWSCosts.region('ap-southeast-1')
      instance_rate = region.ec2.on_demand(:linux).price('t2.medium')
      ebs_rate = 0.12
      storage = 10

      hour = time_to_int / (60 * 60)
      min = (time_to_int / 60) % 60

      return (hour*instance_rate + (min*instance_rate)/60 + (ebs_rate*storage*hour)/(24*30)).round(3)
    end

    def data_tranfer_calculate_cost(network_tx_bytes)
      data = Humanize::Byte.new(network_tx_bytes)
      if data.to_t.value > 100
        return (data.to_g.value * 0.08).round(3)
      elsif data.to_t.value > 40
        return (data.to_g.value * 0.082).round(3)
      elsif data.to_t.value > 10
        return (data.to_g.value * 0.085).round(3)
      elsif data.to_g.value > 1
        return (data.to_g.value * 0.12).round(3)
      else
        return 0
      end
    end

    def instance_status_check(instance_statuses)
      if !instance_statuses.nil?
        if instance_statuses.system_status.status == "ok" && instance_statuses.instance_status.status == "ok"
          @all_pass = true
        else
          @all_pass = false
        end

        if instance_statuses.system_status.status == "initializing" || instance_statuses.instance_status.status == "initializing"
          @status_check_text = '<img src="/assets/initializing.png" alt="Running"> initializing'.html_safe
        elsif instance_statuses.system_status.status == "ok" && instance_statuses.instance_status.status == "ok"
          @status_check_text = '<img src="/assets/pass.png" alt="Running"> 2/2 checks passed'.html_safe
        else
          @status_check_text = ''
          if instance_statuses.system_status.status == "ok"
            @status_check_text += '<img src="/assets/pass.png" alt="Running"> checks passed<br>'
          else
            @status_check_text += '<img src="/assets/status_error.png" alt="Running"> ' + instance_statuses.system_status.status + '<br>'
          end
          if instance_statuses.instance_status.status == "ok"
            @status_check_text += '<img src="/assets/pass.png" alt="Running"> checks passed'
          else
            @status_check_text += '<img src="/assets/status_error.png" alt="Running"> ' + instance_statuses.instance_status.status
          end
          @status_check_text = @status_check_text.html_safe
        end

      else
        @all_pass = false
        @status_check_text = ""
      end
    end

    def get_ec2_instance_information
      ec2 = Aws::EC2::Client.new
      instance = ec2.describe_instance_status(instance_ids:[@node.ec2.instance_id])
      @instance_state = Aws::EC2::Instance.new(@node.ec2.instance_id).state.name
      if !instance.instance_statuses[0].nil?
        @instance_state = instance.instance_statuses[0].instance_state.name
        @public_dns_name = ec2.describe_instances(instance_ids:[instance.instance_statuses[0].instance_id]).reservations[0].instances[0].public_dns_name
        instance_status_check(instance.instance_statuses[0])
      end
      if @instance_state == "running"
        @ec2_cost = calculate_ec2_cost(@kuuser.instance.uptime_seconds + @node.uptime_seconds, @kuuser.instance.network_tx + @node.counters.network.interfaces.eth0.tx.bytes.to_i)
      elsif @instance_state == "stopped"
        @ec2_cost = calculate_ec2_cost(@kuuser.instance.uptime_seconds, @kuuser.instance.network_tx)
      end
    end

end
