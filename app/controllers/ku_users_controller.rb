class KuUsersController < ApplicationController
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
      redirect_to ku_users_path, :notice => "User was saved"
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
      redirect_to ku_users_path, :notice => "User has been updated"
    else
      render "edit"
    end
  end

  def destroy
    @kuuser = KuUser.find(params[:id])
    @kuuser.destroy
    redirect_to ku_users_path, :notice => "User has been deleted"
  end

  private
    def ku_user_params
      params.require(:ku_user).permit(:ku_id, :username, :password, :password_confirmation, :firstname, :lastname, :sex, :email, :degree_level, :faculty, :major_field, :status, :campus)
    end

end
