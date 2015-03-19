class UsersController < ApplicationController
  def index
    @users = KuUser.all  
  end
  
  def show
    @user = KuUser.find(params[:id])
  end

  def new
    @user = KuUser.new
  end

  def create
    @user = KuUser.new(params[:user])
    #@user.save
    if @user.save
      redirect_to users_path, :notice => "User was saved"
    else
      render "new"
    end
  end

  def edit
    @user = KuUser.find(params[:id])
  end

  def update
    @user = KuUser.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to users_path, :notice => "User has been updated"
    else
      render "edit"
  end

  def destroy
    @user = KuUser.find(params[:id])
    @user.destroy
    redirect_to users_path, :notice => "User has been deleted"
  end

  def teacher
    #render :text => "<h1>render teacher</h1>"
  end

  def student

  end
end
