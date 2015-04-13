require 'fileutils'
class ProgramsController < ApplicationController
  def index
    @programs = Program.all.paginate(page: params[:page], per_page: 2)
  end
  
  def show
    @program = Program.find(params[:id])
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
    @program.destroy
    redirect_to programs_path, :notice => "Program has been deleted"
  end

  def create_file(program)
  	directory = "public/cookbooks/"+program.program_name+"/"
  	name = "test.txt"
  	#path = File.join(directory, name)
  	#dirname = File.dirname(path)
  	#unless File.directory?(dirname)
  		#FileUtils.mkdir_p(dirname)
  	#end
        
  	#content = "data from the "+program.program_name
  	#File.open(path, "w+") do |f|
  		#f.write(content)
  	#end

  	#@program_file = ProgramFile.new(program_id: program.id, file_path: path, file_name: program.program_name)
  	#@program_file.save
  	FileUtils.cp 'public/cookbooks/cookbooktemp/', directory

  end

  private
    def program_params
      params.require(:program).permit(:program_name, :note)
    end

end
