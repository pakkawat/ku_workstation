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

  def destroy
    @program = Program.find(params[:id])
    #FileUtils.rm_rf(@program.program_files.first.file_path)
    FileUtils.rm_rf("public/cookbooks/"+@program.program_name)
    @program.destroy
    flash[:success] = "Program has been deleted"
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

end
