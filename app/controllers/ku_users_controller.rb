class KuUsersController < ApplicationController
  def index
    @KuUsers = KuUser.all  
  end
  
  def show
    @KuUser = KuUser.find(params[:id])
  end

  def new
    @KuUser = KuUser.new
  end

  def create
    @KuUser = KuUser.new(ku_user_params)
    #render plain: ku_user_params.inspect
    #@KuUser.save
    if @KuUser.save
      redirect_to ku_users_path, :notice => "User was saved"
    else
      render "new"
    end
  end

  def edit
    @KuUser = KuUser.find(params[:id])
  end

  def update
    @KuUser = KuUser.find(params[:id])

    if @KuUser.update_attributes(ku_user_params)
      redirect_to ku_users_path, :notice => "User has been updated"
    else
      render "edit"
    end
  end

  def destroy
    @user = KuUser.find(params[:id])
    @user.destroy
    redirect_to ku_users_path, :notice => "User has been deleted"
  end

  private
    def ku_user_params
      params.require(:ku_user).permit(:ku_id, :username, :password, :password_confirmation, :firstname, :lastname, :sex, :email, :degree_level, :faculty, :major_field, :status, :campus)
    end

end
