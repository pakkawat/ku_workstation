require 'fileutils'
class ProgramsController < ApplicationController
  include ResourceGenerator
  include KnifeCommand
  def index
    @programs = Program.all
  end
  
  def show
    #if params[:subject].present?
      #render plain: params[:subject].inspect
    #end
    @program = Program.find(params[:id])
    #@program_files = @program.program_files.all
    @directory = "/home/ubuntu/chef-repo/cookbooks/"+@program.program_name
    #@all_files = Dir.glob(directory+'/**/*').sort_by{|e| e}
    @all_directories = Dir.glob(@directory+'/*').select{ |e| File.directory? e }.sort_by{|e| e}#for drop_down

    @current_dir = Dir.glob(@directory+"/*").sort_by{|e| e}
  end

  def new
    @program = Program.new
    #chef_attribute = ChefAttribute.new
    #@builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, chef_attribute, view_context, {})
    #2.times{ @program.chef_resources.build }
    #chef_resource.chef_attributes.build
  end

  def create
    @program = Program.new(program_params)
    #str_temp = ""
    #if chef_resources_attributes not nil
    #params[:program][:chef_resources_attributes].each do |key, value|
      #str_temp += value[:resource_type]+"---"+value[:resource_name]+"----"+value[:_destroy]+"[[["
      #if !value[:chef_attributes_attributes].nil?
        #value[:chef_attributes_attributes].each do |key, value|
          #str_temp += value[:att_value]+"---"+value[:_destroy]+"---"
        #end
      #end
      #str_temp += "]]]"
    #end
    #render plain: str_temp
    #render plain: program_params.inspect#+"-----"+params[:program][:chef_resources_attributes].inspect
    #@KuUser.save
    if @program.save
      if create_file(@program)
        if !params[:program][:chef_resources_attributes].nil?
          generate_chef_resource()
        end
        check_error = system "knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
        if check_error
          flash[:success] = "Program was saved"
          redirect_to programs_path
        else
          flash[:danger] = "Error can not update cookbook"
          redirect_to programs_path
        end
      else
        flash[:danger] = "Error can not create cookbook"
        render "new"
      end
    else
      render "new"
    end
  end

  def edit
    @program = Program.find(params[:id])
  end

  def update
    @program = Program.find(params[:id])
    #render plain: program_params.inspect
    update_resource(program_params)
    
    #if @program.update_attributes(program_params)
      #flash[:success] = "Program has been updated"
      #redirect_to programs_path
    #else
      #render "edit"
    #end
  end

  def destroy# not delete user run_list
    @program = Program.find(params[:id])
    #------- Testtttttttttttttttttttttttttttttttttt
    #@job = Delayed::Job.enqueue ProgramJob.new(@program)
    #str_des = "Delete Program:"+@program.program_name
    #@job.update_column(:description, str_des)
    #flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    #-------- Testttttttttttttttttttttttt
    FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name)
    @program.destroy
    redirect_to programs_path
  end

  def create_file(program)
    check_error = system "knife cookbook create " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
    if check_error #if not error (true)
    	directory = "/home/ubuntu/chef-repo/cookbooks/"+program.program_name
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

    	#FileUtils.cp_r('public/cookbooks/cookbooktemp/.', directory)
      #all_files = Dir.glob(directory+'/**/*').select{ |e| File.file? e }
      #all_files.each do |file_name|
        #text = File.read(file_name)
        #new_contents = text.gsub("cookbooktemp", program.program_name)
        #File.open(file_name, "w") {|file| file.puts new_contents }
      #end

      File.open(directory+"/recipes/default.rb", 'a') do |f|
        f.write("\n")
        f.write("include_recipe \'#{program.program_name}::remove_files\'")
        f.write("\n")
        f.write("include_recipe \'#{program.program_name}::uninstall_programs\'")
        f.write("\n")
      end
      output = File.open(directory+"/recipes/remove_files.rb","w")
      output << ""
      output.close
      output = File.open(directory+"/recipes/uninstall_programs.rb","w")
      output << ""
      output.close
      # to_do # upload "knife cookbook upload remove-xxx"
    end

    return check_error

  end

  def generate_chef_resource()
    File.open("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/recipes/default.rb", 'a') do |f|
      @program.chef_resources.each do |chef_resource|
        f.write(ResourceGenerator.resource(chef_resource))
      end
    end
  end

  def upload_cookbook222
    program = Program.find(params[:program_id])
    check_error = system "knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
    if check_error
      flash[:success] = program.program_name + " has been updated"
      redirect_to program_path(program)
    else
      flash[:danger] = "Error can not update cookbook"
      redirect_to program_path(program)
    end
  end


  def upload_cookbook
    program = Program.find(params[:program_id])
    check_error, error_msg = KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb")
    if check_error
      flash[:success] = program.program_name + " has been updated"
      redirect_to program_path(program)
    else
      flash[:danger] = error_msg
      redirect_to program_path(program)
    end
  end

  def update_resource(program_params)
    str_temp = ""
    params[:program][:chef_resources_attributes].each do |key, value|
      if value[:_destroy] == "false"
        str_temp += value.to_s+"---"

        if value[:id].nil?# new value
          str_temp += "new[[["+value[:chef_attributes_attributes].to_s+"]]]---"
          #update_new_resource(chef_resource)
        else # old value ( delete old file)
          str_temp += "old[[["+value[:chef_attributes_attributes].to_s+"]]]---"
        end

      else # resource has been deleted (delete old file and uninstall program)
        str_temp += "delete_resource[["+value.to_s+"]]---"
      end
    end
    render plain: str_temp+"||||||||||||"+program_params.inspect
  end

  def update_new_resource(chef_resource)
    File.open("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/recipes/default.rb", 'a') do |f|
      f.write(ResourceGenerator.add_resource(chef_resource))
    end
  end

  def chef_remote_files_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    #render plain: params[:form_id].inspect+"--"+@form_id.to_s[2..-3]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  def chef_package_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  def chef_deb_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  private
    def program_params
      params.require(:program).permit(:program_name, :note, chef_resources_attributes: [ :id, :resource_name, :resource_type, :_destroy, chef_attributes_attributes: [ :id, :att_type, :att_value, :_destroy ] ] )
    end

    def add_remove_program_to_run_list
      #Subject.where(id: ProgramsSubject.select("subject_id").where(:program_id => @program.id, :program_enabled => true)).each do |subject|
        #KuUser.where(id: subject.user_subjects.select("ku_user_id").where(user_enabled: true)).each do |user|
          #user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", "recipe[remove-" + @program.program_name + "],"))
        #end
      #end
      KuUser.where(id: UserSubject.select("ku_user_id").where(subject_id: @program.subjects)).each do |user|
        user.update_column(:run_list, user.run_list.gsub("recipe[" + @program.program_name + "],", "recipe[remove-" + @program.program_name + "],"))
      end
    end

    def apply_run_list
      str_temp = ""
      #Subject.where(id: ProgramsSubject.select("subject_id").where(program_id: @program.id)).each do |subject|
        #subject.ku_users.each do |user|# send run_list to Chef-server and run sudo chef-clients
          #if !user.run_list.blank?
            #str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')
            #str_temp += " || "
            #user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + @program.program_name + "],", ""))
          #end
        #end
        #subject.programs_subjects.where(program_id: @program.id).destroy_all
      #end

      KuUser.where(id: UserSubject.select("ku_user_id").where(subject_id: @program.subjects)).each do |user|# send run_list to Chef-server and run sudo chef-clients
        str_temp += "ku_id: " + user.ku_id + " - run_list:" + user.run_list.gsub(/\,$/, '')+" || "
        user.update_column(:run_list, user.run_list.gsub("recipe[remove-" + @program.program_name + "],", ""))
      end
      @program.subjects.destroy_all
      return str_temp
    end

end
