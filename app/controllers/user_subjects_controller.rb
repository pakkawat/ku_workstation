class UserSubjectsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])  
    @subjectusers = @subject.ku_users.paginate(page: params[:subjectuser_page], per_page: 2).order("ku_id ASC")
    @kuusers = KuUser.where.not(id: @subject.ku_users).paginate(page: params[:kuuser_page], per_page: 2).order("ku_id ASC")
  end

  def create
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    @subject.user_subjects.create(ku_user: @kuuser)
    add_program_to_run_list
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  def destroy
    @kuuser = KuUser.find(params[:ku_user_id])
    @subject = Subject.find(params[:subject_id])
    UserSubject.find_by(ku_user_id: @kuuser.id, subject_id: @subject.id).destroy
    add_remove_program_to_run_list
    redirect_to subject_user_subjects_path(:subject_id => @subject.id)
  end

  private
    def subject_apply# send run_list to Chef-server and run sudo chef-clients then if any remove need update user.run_list
      str_temp = ""
      @subject = Subject.find(params[:subject_id])
      @subject.ku_users.each do |user|
        str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
        str_temp += " || "
        user.update_column(:run_list, @kuuser.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
        # delete recipe[remove-xxx], from user.run_list
      end

      render plain: str_temp.inspect
    end

    def add_program_to_run_list
      str_temp = ""
      @kuuser = KuUser.find(params[:ku_user_id])
      @subject = Subject.find(params[:subject_id])
      @subject.programs.each do |program|
        #str_temp += "ku_id: " + user.ku_id + " add recipe[" + @program.program_name + "] || "
        @kuuser.update_column(:run_list, @kuuser.run_list.to_s + "recipe[" + program.program_name + "],")
      end
      #KuUser.where.not(id: @subject.ku_users).update_all(:run_list => true)
    end

    def add_remove_program_to_run_list
      str_temp = ""
      @kuuser = KuUser.find(params[:ku_user_id])
      @subject = Subject.find(params[:subject_id])
      @subject.programs.each do |program|
        @kuuser.update_column(:run_list, @kuuser.run_list.gsub("recipe[" + program.program_name + "],", "recipe[remove-" + program.program_name + "],"))
      end
    end
end
