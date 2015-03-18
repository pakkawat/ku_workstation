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

  end

  def update

  end

  def destroy

  end

  def teacher
    #render :text => "<h1>render teacher</h1>"
  end

  def student

  end
end
