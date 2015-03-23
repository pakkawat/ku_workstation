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
    render plain: params[:user].inspect
    #@user.save
    #if @user.save
      #redirect_to users_path, :notice => "User was saved"
      #render "edit"
    #else
      #render "new"
    #end
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
  end

  def destroy
    
  end

  def teacher
    #render :text => "<h1>render teacher</h1>"
  end

  def student

  end

  private
    def user_params
      #params.require(:user).permit(:ku_id, :username, :password, :password_confirmation, :firstname, :lastname, :sex, :email, :degree_level, :faculty, :major_field, :status, :campus)
    end
end
