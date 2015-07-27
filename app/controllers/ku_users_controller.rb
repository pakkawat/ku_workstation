class KuUsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  def index
    @kuusers = KuUser.all
  end
  
  def show
    @kuuser = KuUser.find(params[:id])
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
      @job = Delayed::Job.enqueue KuUserJob.new(@kuuser.id,"create")
      str_des = "Create instance:"+@kuuser.ku_id
      @job.update_column(:description, str_des)
      flash[:success] = str_des+" with Job ID:"+@job.id.to_s

      redirect_to ku_users_path
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
    @job = Delayed::Job.enqueue KuUserJob.new(@kuuser.id,"delete")
    
    str_des = "Delete instance:"+@kuuser.ku_id
    @job.update_column(:description, str_des)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s

    #@kuuser.find(params[:id]).destroy
    #flash[:success] = "User deleted"
    redirect_to ku_users_path
  end

  private
    def ku_user_params
      params.require(:ku_user).permit(:ku_id, :username, :password, :password_confirmation, :firstname, :lastname, :sex, :email, :degree_level, :faculty, :major_field, :status, :campus)
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
