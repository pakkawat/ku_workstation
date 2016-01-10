require 'fileutils'
require 'uri'
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
  end

  def create
    @program = Program.new(program_params)

    if @program.save
      if create_file(@program)
        if !params[:program][:chef_resources_attributes].nil?
          generate_chef_resource
        end
        #check_error = system "knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
        #if check_error
          #flash[:success] = "Program was saved"
          redirect_to programs_path
        #else
          #flash[:danger] = "Error can not upload cookbook to server"
          #redirect_to programs_path
        #end
      else
        flash[:danger] = "Error can not create program #{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
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
    check_chef_resource
    if @program.update_attributes(program_params)
      generate_chef_resource
      if KnifeCommand.run("knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        flash[:success] = "Program has been updated"
        redirect_to @program
      else
        flash[:danger] = "Error can not update program  #{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
        redirect_to @program
      end
    else
      render "edit"
    end
  end


  def update2
    @program = Program.find(params[:id])
    #render plain: program_params.inspect
    check_chef_resource
    if @program.update_attributes(program_params)
      generate_chef_resource
      flash[:success] = "Program has been updated"
      redirect_to programs_path
    else
      render "edit"
    end
  end


  def destroy# not delete user run_list
    @program = Program.find(params[:id])
    #------- Testtttttttttttttttttttttttttttttttttt
    #check_error, error_msg = KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb")
    #if check_error
      #@job = Delayed::Job.enqueue ProgramJob.new(@program,"delete")
      #str_des = "Delete Program:"+@program.program_name
      #@job.update_column(:description, str_des)
      #flash[:success] = str_des+" with Job ID:"+@job.id.to_s
      #redirect_to programs_path
    #else
      #flash[:danger] = error_msg
      #redirect_to program_path(program)
    #end
    #-------- Testttttttttttttttttttttttt
    FileUtils.rm_rf("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name)
    @program.destroy
    redirect_to programs_path
  end

  def create_file(program)
    check_error = KnifeCommand.run("knife cookbook create " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
    if check_error #if not error (true)
    	directory = "/home/ubuntu/chef-repo/cookbooks/"+program.program_name

    	@program_file = ProgramFile.new(program_id: program.id, file_path: directory, file_name: program.program_name)
    	@program_file.save

      File.open(directory+"/recipes/default.rb", 'a') do |f|
        f.write("\n")
        f.write("include_recipe \'#{program.program_name}::remove_disuse_resources\'")
        f.write("\n\n")
      end
      FileUtils.mv directory+"/recipes/default.rb", directory+"/recipes/header.rb"
      File.open(directory+"/recipes/default.rb", 'w') do |f|
        f.write("\n")
        f.write("include_recipe \'#{program.program_name}::header\'")
        f.write("\n\n")
        f.write("if node[\'user_list\'].include?(node.name)")
        f.write("\n")
        f.write("  include_recipe \'#{program.program_name}::install_programs\'")
        f.write("\n")
        f.write("else")
        f.write("\n")
        f.write("  include_recipe \'#{program.program_name}::uninstall_programs\'")
        f.write("\n")
        f.write("end")
        f.write("\n\n")
      end
      output = File.open(directory+"/recipes/install_programs.rb","w")
      output << ""
      output.close
      output = File.open(directory+"/recipes/uninstall_programs.rb","w")
      output << ""
      output.close
      output = File.open(directory+"/recipes/remove_disuse_resources.rb","w")
      output << ""
      output.close
      
      File.open(directory+"/attributes/default.rb", 'w') do |f|
        f.write("\n")
        f.write("include_attribute \'#{program.program_name}::user_list\'")
        f.write("\n\n")
      end
      output = File.open(directory+"/attributes/user_list.rb","w")
      output << ""
      output.close
    end

    return check_error

  end

  def generate_chef_resource
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/install_programs.rb", 'w') do |f|
      @program.chef_resources.each do |chef_resource|
        f.write(ResourceGenerator.resource(chef_resource))
      end
    end

    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/uninstall_programs.rb", 'w') do |f|
      @program.chef_resources.each do |chef_resource|
        f.write(ResourceGenerator.uninstall_resource(chef_resource))
      end
    end

    remove_files = RemoveFile.where(program_id: @program.id)
    File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
      remove_files.each do |file|
        f.write(ResourceGenerator.remove_disuse_resource(file))
      end
    end
  end

  def upload_cookbook
    program = Program.find(params[:program_id])
    if KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      flash[:success] = program.program_name + " has been updated"
      redirect_to program_path(program)
    else
      flash[:danger] = "there are something wrong see system.log"
      redirect_to program_path(program)
    end
  end

  def apply_change
    @program = Program.find(params[:program_id])
    @job = Delayed::Job.enqueue ProgramJob.new(@program.id,"apply_change")
    str_des = "Apply change on Program:"+@program.program_name
    @job.update_column(:description, str_des)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    redirect_to @program
  end

  def check_chef_resource
    params[:program][:chef_resources_attributes].each do |key, value|
      if value[:_destroy] == "false"
        #str_temp += value.to_s+"---"

        if !value[:id].nil? #chef_resource old value ( if different delete old file)
          #str_temp += "old[[["+value[:chef_attributes_attributes].to_s+"]]]---"
          chef_resource = ChefResource.find(value[:id])
          if value[:resource_type] == "Repository" # because Repository does not has chef_attribute
            new_resource_name = value[:resource_name]
            if chef_resource.resource_name != new_resource_name
              diff_resource_name = find_diff_resource_name(chef_resource.resource_name, new_resource_name)
              remove_file = RemoveFile.new(program_id: @program.id, chef_resource_id: chef_resource.id, resource_type: chef_resource.resource_type, resource_name: diff_resource_name, att_type: "", att_value: "")
              remove_file.save
            end
          else
            check_chef_attribute(chef_resource, value[:chef_attributes_attributes])
          end
        end
      else # chef_resource has been deleted (delete old file and uninstall program)
        remove_resource(chef_resource)
      end
    end
  end

  def find_diff_resource_name(resource1, resource2)
    array1 = resource1.split(' ')
    array2 = resource2.split(' ')
    return (array1 - array2).join(" ")
  end

  def check_chef_attribute(chef_resource, chef_attributes)
    chef_attributes.each do |key, value|
      if value[:_destroy] == "false"
        if !value[:id].nil? #chef_attribute old value ( if different delete old file)
          chef_att = ChefAttribute.find(value[:id])
          if chef_att.att_value != value[:att_value]
            remove_resource(chef_resource)
          end
        end
      else
        remove_resource(chef_resource)
      end
    end
  end

  def remove_resource(chef_resource)
    if !@program.remove_files.find_by(chef_resource_id: chef_resource.id).present? # check Is chef_resource_id alredy in remove_files
      if chef_resource.resource_type == "Repository"
        remove_file = RemoveFile.new(program_id: @program.id, chef_resource_id: chef_resource.id, resource_type: chef_resource.resource_type, resource_name: chef_resource.resource_name, att_type: "", att_value: "")
        remove_file.save
      else
        chef_resource.chef_attributes.each do |chef_attribute|
          #if chef_attribute.att_type == "source" || chef_attribute.att_type == "extract_path"
          remove_file = RemoveFile.new(program_id: @program.id, chef_resource_id: chef_resource.id, resource_type: chef_resource.resource_type, resource_name: chef_resource.resource_name, att_type: chef_attribute.att_type, att_value: chef_attribute.att_value)
          remove_file.save
        end
      end
    end
  end

  def install_repository_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  def install_dep_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  def install_source_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  def download_file_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  def extract_file_partial
    @program = nil
    @form_id = params[:form_id].to_s[2..-3]
    @form_type = params[:form_type]
    @chef_attribute = ChefAttribute.new
    @builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, @chef_attribute, view_context, {})
    respond_to do |format|
      format.js
    end
  end

  def sort
    program = Program.find(params[:program_id])
    params[:order].each do |key,value|
      program.chef_resources.find_by(id: value[:id]).update_attribute(:priority,value[:position])
    end
    render :nothing => true
  end

  private
    def program_params
      params.require(:program).permit(:program_name, :note, chef_resources_attributes: [ :id, :resource_name, :resource_type, :file_name, :_destroy, chef_attributes_attributes: [ :id, :att_type, :att_value, :_destroy ] ] )
    end
end
