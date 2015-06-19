class SubjectsController < ApplicationController
  def index
    @subjects = Subject.all  
  end
  
  def show
    @subject = Subject.find(params[:id])
  end

  def new
    @subject = Subject.new
  end

  def create
    @subject = Subject.new(subject_params)
    #render plain: ku_user_params.inspect
    #@KuUser.save
    if @subject.
      flash[:success] = "Subject was saved"
      redirect_to subjects_path
    else
      render "new"
    end
  end

  def edit
    @subject = Subject.find(params[:id])
  end

  def update
    @subject = Subject.find(params[:id])

    if @subject.update_attributes(subject_params)
      flash[:success] = "Subject has been updated"
      redirect_to subjects_path
    else
      render "edit"
    end
  end

  def destroy
    @subject = Subject.find(params[:id])
    update_users_run_list
    #@subject.destroy
    #flash[:success] = ""
    #redirect_to subjects_path, :notice => "Subject has been deleted"
  end

  private
    def subject_params
      params.require(:subject).permit(:subject_id, :subject_name, :term, :year)
    end

    def update_users_run_list
      str_temp = ""
      @subject.programs.each do |program|
        @subject.ku_users.each do |user|
          #user.update_column(:run_list, user.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"))
          
          str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],")
          str_temp += " || "
        end
      end
      # 1. send run_list to chef-server
      # 2. update run_list recipe[remove-xxx] to ''
      #@subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
        #if !user.run_list.blank?
          #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
          #str_temp += " || "
        #end
      #end
      render plain: str_temp.inspect
    end
end
