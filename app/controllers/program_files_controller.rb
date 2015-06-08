class ProgramFilesController < ApplicationController
  def index
  end
  def show
  	@program = Program.find(params[:id])
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
end
