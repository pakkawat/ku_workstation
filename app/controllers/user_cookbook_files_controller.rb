class UserCookbookFilesController < ApplicationController
  #before_action :set_user_cookbook_file, only: [:show, :edit, :update, :destroy]

  # GET /user_cookbook_files
  # GET /user_cookbook_files.json
  def index
    @user_cookbook_files = UserCookbookFile.all
  end

  # GET /user_cookbook_files/1
  # GET /user_cookbook_files/1.json
  def show
    @kuuser = KuUser.find(params[:id])
    @user_dir = "/home/ubuntu/chef-repo/cookbooks/"+@kuuser.ku_id+"/"
    @path = params[:cookbook_paths].sub(/^#{@kuuser.ku_id}\//, '')
    if @path == @kuuser.ku_id # if it true then it is home directory
      @path = ""
    end
    @current_file = @user_dir+@path
    if File.directory?(@current_file)
      @all_files = Dir.glob(@current_file+"/*").sort_by{|e| e}
    elsif File.file?(@current_file)
      @data = File.read(@current_file)
    end
  end

  # GET /user_cookbook_files/new
  def new
    @user_cookbook_file = UserCookbookFile.new
  end

  # GET /user_cookbook_files/1/edit
  def edit
  end

  # POST /user_cookbook_files
  # POST /user_cookbook_files.json
  def create
    @user_cookbook_file = UserCookbookFile.new(user_cookbook_file_params)

    respond_to do |format|
      if @user_cookbook_file.save
        format.html { redirect_to @user_cookbook_file, notice: 'User cookbook file was successfully created.' }
        format.json { render :show, status: :created, location: @user_cookbook_file }
      else
        format.html { render :new }
        format.json { render json: @user_cookbook_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_cookbook_files/1
  # PATCH/PUT /user_cookbook_files/1.json
  def update
    respond_to do |format|
      if @user_cookbook_file.update(user_cookbook_file_params)
        format.html { redirect_to @user_cookbook_file, notice: 'User cookbook file was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_cookbook_file }
      else
        format.html { render :edit }
        format.json { render json: @user_cookbook_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_cookbook_files/1
  # DELETE /user_cookbook_files/1.json
  def destroy
    @user_cookbook_file.destroy
    respond_to do |format|
      format.html { redirect_to user_cookbook_files_url, notice: 'User cookbook file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_cookbook_file
      @user_cookbook_file = UserCookbookFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_cookbook_file_params
      params[:user_cookbook_file]
    end
end
