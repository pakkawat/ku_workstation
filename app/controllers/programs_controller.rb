require 'fileutils'
class ProgramsController < ApplicationController
  def index
    @programs = Program.all
  end
  
  def show
    #if params[:subject].present?
      #render plain: params[:subject].inspect
    #end
    @program = Program.find(params[:id])
    #@program_files = @program.program_files.all
    @directory = "public/cookbooks/"+@program.program_name
    #@all_files = Dir.glob(directory+'/**/*').sort_by{|e| e}
    @all_directories = Dir.glob(@directory+'/*').select{ |e| File.directory? e }.sort_by{|e| e}#for drop_down

    @current_dir = Dir.glob(@directory+"/*").sort_by{|e| e}
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new(program_params)
    #render plain: ku_user_params.inspect
    #@KuUser.save
    if @program.save
      create_file(@program)
      flash[:success] = "Program was saved"
      redirect_to programs_path
    else
      render "new"
    end
  end

  def edit
    @program = Program.find(params[:id])
  end

  def update
    @program = Program.find(params[:id])

    if @program.update_attributes(program_params)
      flash[:success] = "Program has been updated"
      redirect_to programs_path
    else
      render "edit"
    end
  end

  def destroy# not delete user run_list
    @program = Program.find(params[:id])
    add_remove_program_to_run_list
    str_temp = apply_run_list
    #FileUtils.rm_rf(@program.program_files.first.file_path)
    FileUtils.rm_rf("public/cookbooks/"+@program.program_name)
    @program.destroy
    flash[:success] = str_temp
    #flash[:success] = "Program has been deleted"
    redirect_to programs_path
  end

  def create_file(program)
  	directory = "public/cookbooks/"+program.program_name
  	#name = "test.txt"
  	#path = File.join(directory, name)
  	#dirname = File.dirname(path)
  	#unless File.directory?(dirname)
  		#FileUtils.mkdir_p(dirname)
  	#end
        
  	#content = "data from the "+program.program_name
  	#File.open(path, "w+") do |f|
  		#f.write(content)
  	#end

  	@program_file = ProgramFile.new(program_id: program.id, file_path: directory, file_name: program.program_name)
  	@program_file.save
  	FileUtils.cp_r('public/cookbooks/cookbooktemp/.', directory)
    #all_files = Dir.glob(directory+"/*")
    all_files = Dir.glob(directory+'/**/*').select{ |e| File.file? e }
    all_files.each do |file_name|
      text = File.read(file_name)
      new_contents = text.gsub("cookbooktemp", program.program_name)
      File.open(file_name, "w") {|file| file.puts new_contents }
    end
  end

  private
    def program_params
      params.require(:program).permit(:program_name, :note)
    end

    def add_remove_program_to_run_list
      Subject.where(id: ProgramsSubject.select("subject_id").where(:program_id => @program.id, :program_enabled => true)).each do |subject|
        KuUser.where(id: subject.user_subjects.select("ku_user_id").where(user_enabled: true)).each do |user|
          user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", "recipe[remove-" + @program.program_name + "],"))
        end
      end
    end

    def apply_run_list
      str_temp = ""
      Subject.where(id: ProgramsSubject.select("subject_id").where(program_id: @program.id)).each do |subject|
        subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
          if !user.run_list.blank?
            str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
            str_temp += " || "
            user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + program.program_name + "],", ""))
          end
        end
        subject.programs_subjects.where(program_id: @program.id).destroy_all
      end
      return str_temp
    end

end
