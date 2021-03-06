class ProgramFilesController < ApplicationController
  def index
  end
  def show
  	@program = Program.find(params[:program_id])
  	@program_dir = "/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/"
  	@path = params[:program_files]
  	@current_file = @program_dir+@path
  	if File.directory?(@current_file)
  	  @all_files = Dir.glob(@current_file+"/*").sort_by{|e| e}
  	  @all_directories = Dir.glob(@current_file+"/*").select{ |e| File.directory? e }.sort_by{|e| e}#for dropdown
  	elsif File.file?(@current_file)
  	  @data = File.read(@current_file)
  	else
  	  #file not found
  	end
  end

  def new_file
  	@program = Program.find(params[:program_id])
  	@program_dir = "/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/"
  	@path = ""
  	if params[:program_files] == "create_from_loot_dir_form_tag" # form_tag view/programs/show.html.erb
  		@path = ""
      @program_dir = @program_dir.chomp("/") # fix double slash("//") when create file from root folder and select current dir ("/")
  	else
  		@path = params[:program_files]
  	end
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
  				flash[:success] = "Folder was successfully created at "+full_path.gsub("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name, "")
  			end
  		else #new file
  			if params[:name].index(".").present? && params[:name][-1] != "."
  				if File.exists?(full_path)
  					flash[:danger] = "A File with the same name already exists. Please choose a different name and try again."
  				else
  					File.open(full_path, "w+") do |f|
  						f.write("")
  					end
  					flash[:success] = "File was successfully created at "+full_path.gsub("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name, "")
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
  	redirect_to program_path(@program)+full_path.gsub("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name, "")

  end

  def save_file
    @program = Program.find(params[:program_id])
    @program_dir = "/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/"
    @path = params[:program_files]
    @current_file = @program_dir+@path
    File.open(@current_file, "w+") do |f|
      f.write(params[:file_data])
    end
    flash[:success] = "File was saved"
    redirect_to program_path(@program)+"/"+@path
  end

  def delete_file
  	@program = Program.find(params[:program_id])
  	@program_dir = "/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/"
  	@path = params[:program_files]
  	@current_file_path = @program_dir+@path
  	#render plain: @current_file_path.inspect+" || Name:"+params[:name]
  	FileUtils.rm_rf(@current_file_path)
  	flash[:success] = "File successfully deleted."
  	#@current_file_path = @current_file_path.chomp(params[:name])
  	redirect_to program_path(@program)+@current_file_path.gsub("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name, "").chomp(params[:name])
  end
end
