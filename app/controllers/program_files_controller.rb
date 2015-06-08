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
  	elsif File.file?(@current_file)
  	  @data = File.read(@current_file)
  	else
  	  #file not found
  	end
  end

  def save_file
    @program = Program.find(params[:program_id])
    @program_dir = "public/cookbooks/"+@program.program_name+"/"
    @path = params[:program_files]
    @current_file = @program_dir+@path
    File.open(@current_file, "w+") do |f|
      f.write(params[:file_data])
    end
    redirect_to @program, :notice => "File was saved"
  end	
end
