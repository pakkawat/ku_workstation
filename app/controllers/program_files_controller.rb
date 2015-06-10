class ProgramFilesController < ApplicationController
  def index
  end
  def show
  	@program = Program.find(params[:program_id])
  	@program_dir = "public/cookbooks/"+@program.program_name+"/"
  	@path = params[:program_files]
  	@current_file = @program_dir+@path
  	if File.directory?(@current_file)
  	  @all_files = Dir.glob(@current_file+"/*").sort_by{|e| e}
  	  @all_directory = Dir.glob(@current_file+"/*").select{ |e| File.directory? e }.sort_by{|e| e}#for dropdown
  	elsif File.file?(@current_file)
  	  @data = File.read(@current_file)
  	else
  	  #file not found
  	end
  end

  def new_file
  	@program = Program.find(params[:program_id])
  	@program_dir = "public/cookbooks/"+@program.program_name+"/"
  	@path = params[:program_files]
  	@current_file_path = @program_dir+@path
  	full_path = ""
  	#render plain: @current_file_path.inspect+" || Type: "+params[:type]+" || New Path: "+params[:new_file_path]+" || Name:"+params[:name]
  	if params[:name].blank?
  		error_msg = ""
  		if params[:type] == "1"
  			error_msg = "Please enter folder name."
  		else
  			error_msg = "Please enter file name."
  		end
  		flash[:danger] = error_msg
  	else
  		if params[:new_file_path].blank?
  			full_path = @current_file_path
  		else
  			full_path = params[:new_file_path]
  		end
  		full_path += "/" + params[:name]
  		if params[:type] == "1" #new directory
  			if File.exists?(full_path)
  				flash[:danger] = "A Folder with the same name already exists. Please choose a different name and try again."
  			else
  				FileUtils.mkdir_p(full_path)
  				flash[:success] = "Folder has been created at "+full_path.gsub("public/cookbooks/"+@program.program_name, "")
  			end
  		else #new file
  			if params[:name].index(".").present? && params[:name][-1] != "."
  				if File.exists?(full_path)
  					flash[:danger] = "A File with the same name already exists. Please choose a different name and try again."
  				else
  					File.open(full_path, "w+") do |f|
  						f.write("")
  					end
  					flash[:success] = "File has been created at "+full_path.gsub("public/cookbooks/"+@program.program_name, "")
  				end
  			else
  				flash[:danger] = "File name was incorrect format. Please try again."
  				if params[:new_file_path].blank?
  					full_path = @current_file_path
  				else
  					full_path = params[:new_file_path]
  				end
  			end
  		end
  	end
  	redirect_to program_path(@program)+full_path.gsub("public/cookbooks/"+@program.program_name, "")

  end

  def save_file
    @program = Program.find(params[:program_id])
    @program_dir = "public/cookbooks/"+@program.program_name+"/"
    @path = params[:program_files]
    @current_file = @program_dir+@path
    File.open(@current_file, "w+") do |f|
      f.write(params[:file_data])
    end
    redirect_to program_path(@program)+"/"+@path, :notice => "File was saved"
  end

  def delete_file
  	@program = Program.find(params[:program_id])
  	@program_dir = "public/cookbooks/"+@program.program_name+"/"
  	@path = params[:program_files]
  	@current_file_path = @program_dir+@path
  	#render plain: @current_file_path.inspect+" || Name:"+params[:name]
  	FileUtils.rm_rf(@current_file_path)
  	flash[:success] = "File successfully deleted."
  	@current_file_path = @current_file_path.gsub(params[:name], "")
  	redirect_to program_path(@program)+@current_file_path.gsub("public/cookbooks/"+@program.program_name, "")
  end
end
