require 'fileutils'
class ProgramsController < ApplicationController
  def index
    @programs = Program.all.paginate(page: params[:page], per_page: 2)
  end
  
  def show
    #if params[:subject].present?
      #render plain: params[:subject].inspect
    #end
    @program = Program.find(params[:id])
    #@program_files = @program.program_files.all
    directory = "public/cookbooks/"+@program.program_name
    @all_files = Dir.glob(directory+'/**/*').sort_by{|e| e}
    @all_directories = Dir.glob(directory+'/**/*').select{ |e| File.directory? e }.sort_by{|e| e}
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
      redirect_to programs_path, :notice => "Program was saved"
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
      redirect_to programs_path, :notice => "Program has been updated"
    else
      render "edit"
    end
  end

  def destroy
    @program = Program.find(params[:id])
    #FileUtils.rm_rf(@program.program_files.first.file_path)
    FileUtils.rm_rf("public/cookbooks/"+@program.program_name)
    @program.destroy
    redirect_to programs_path, :notice => "Program has been deleted"
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

  def new_file
    @program = Program.find(params[:id])
    if params[:name].present?
      path = ""
      if params[:path] == ""
        path = "public/cookbooks/"+@program.program_name+"/"
      else
        path = params[:path]+"/"
      end
      full_path = path+params[:name]
      if params[:type] == "1"
        if File.exists?(full_path)
          flash[:danger] = "Folder at "+full_path.gsub("public/cookbooks/"+@program.program_name, "")+" already exits."
        else
          FileUtils.mkdir_p(full_path)
          flash[:success] = "Folder has been created at "+full_path.gsub("public/cookbooks/"+@program.program_name, "")
        end
      else
        if params[:name].index(".").present? && params[:name][-1] != "."
          if File.exists?(full_path)
            flash[:danger] = "File at "+full_path.gsub("public/cookbooks/"+@program.program_name, "")+" already exits."
          else
            File.open(full_path, "w+") do |f|
              f.write("")
            end
            flash[:success] = "File has been created at "+full_path.gsub("public/cookbooks/"+@program.program_name, "")
          end
        else
          flash[:danger] = "File name was incorrect format"
        end
      end #if params[:type] == "1"
      #render plain: params[:type].inspect+"-"+params[:path].inspect+"-"+params[:name].inspect
    else
      error_msg = ""
      if params[:type] == "1"
        error_msg = "Please enter folder name."
      else
        error_msg = "Please enter file name."
      end
      flash[:danger] = error_msg
    end
    redirect_to @program
    #@program = Program.find(params[:id])
    #redirect_to @program, :notice => "File was created"
  end

  def delete_file
    #if params[:path].present?
      #render plain: params[:path].inspect+"-"+params[:id].inspect
    #end
    @program = Program.find(params[:id])
    FileUtils.rm_rf(params[:path])
    flash[:success] = "File at "+params[:path].gsub("public/cookbooks/"+@program.program_name, "")+" has been deleted."
    redirect_to @program
  end

  def view_file
    @program_id = params[:id]
    @file_path = params[:path]
    @data = File.read(@file_path)
  end

  def save_file
    @program = Program.find(params[:id])
    File.open(params[:path], "w+") do |f|
      f.write(params[:file_data])
    end
    redirect_to @program, :notice => "File was saved"
  end

  private
    def program_params
      params.require(:program).permit(:program_name, :note)
    end

end
