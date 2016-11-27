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
    if params[:program_name] != ""
      program = Program.new(program_name: params[:program_name], note: params[:note])
      if program.save
        if program.update_attribute(:owner, current_user.id)
          if create_file(program)
            #check_error = system "knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb"
            #if check_error
              flash[:success] = "Program was created"
              #redirect_to programs_path
            #else
              #flash[:danger] = "Error can not upload cookbook to server"
              #redirect_to programs_path
            #end
          else
            flash[:danger] = "Error can not create program #{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
          end
        else
          flash[:danger] = "Error update program owner with user:" + current_user.firstname
        end
      else
        flash[:danger] = program.errors.full_messages.first
      end
    else
      flash[:danger] = "Program name cannot be null or empty."
    end
    redirect_to dashboard_index_path
  end

  def create_old
    @program = Program.new(program_params)

    if @program.save
      if create_file(@program)
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
    @chef_resources = @program.chef_resources.where(status: "install")
    @removes = @program.chef_resources.where.not(status: "install")
    check_config_file
  end

  def update2
    @program = Program.find(params[:id])
    #render plain: program_params.inspect

    if @program.update_attribute(:note, params[:program][:note])
      test_generate_chef_resource
      if KnifeCommand.run("knife cookbook upload " + @program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
        flash[:success] = "Program was successfully updated"
        redirect_to edit_program_path(@program)
      else
        flash[:danger] = "Error can not update program  #{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
        redirect_to edit_program_path(@program)
      end
    else
      flash[:danger] = "Error can not update program  #{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
      render "edit"
    end
  end

  def update
    @program = Program.find(params[:id])
    #render plain: program_params.inspect

    if @program.update_attribute(:note, params[:program][:note])
      flash[:success] = "Note was successfully updated"
      redirect_to edit_program_path(@program)
    else
      flash[:danger] = "Error can not update note"
      render "edit"
    end
  end

  def destroy
    @program = Program.find(params[:id])
    @job = Delayed::Job.enqueue ProgramJob.new(@program,"delete")
    str_des = "Delete Program:"+@program.program_name
    @job.update_attributes(:program_id => @program.id, :description => str_des, :owner => current_user.id)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    redirect_to dashboard_index_path
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
        f.write("if node['#{program.program_name}']['user_list'].include?(node.name)")
        f.write("\n")
        f.write("  if CheckUserConfig.user_config_#{program.id}(node['#{program.program_name}']['user_config_list'])\n")
        f.write("    include_recipe \'#{program.program_name}::install_programs\'")
        f.write("\n")
        f.write("  end\n")
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

  def upload_cookbook
    program = Program.find(params[:program_id])
    if KnifeCommand.run("knife cookbook upload " + program.program_name + " -c /home/ubuntu/chef-repo/.chef/knife.rb", nil)
      flash[:success] = program.program_name + " was successfully updated"
      redirect_to program_path(program)
    else
      flash[:danger] = "there are something wrong see #{ActionController::Base.helpers.link_to 'system.log', '/logs/system_log'}"
      redirect_to program_path(program)
    end
  end

  def apply_change
    @program = Program.find(params[:program_id])
    @job = Delayed::Job.enqueue ProgramJob.new(@program,"apply_change")
    str_des = "Apply change on Program:"+@program.program_name
    @job.update_attributes(:program_id => @program.id, :description => str_des, :owner => current_user.id)
    flash[:success] = str_des+" with Job ID:"+@job.id.to_s
    redirect_to programs_path
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
      params.require(:program).permit(:program_name, :note )
    end

    def check_config_file
      chef_resources = @program.chef_resources.where(:resource_type => "Config_file")
      if chef_resources.any?
        chef_resources.each do |chef_resource|
          value = chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
          if !value.nil?
        		file_name = File.basename(value)
            file_full_path = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb"
            if !File.exists?(file_full_path)
              donwload_config_file(file_name, file_full_path)
            end
          end
        end
      end
    end

    def donwload_config_file(file_name, file_full_path)
      require 'chef'
      require 'open-uri'
      error = false
      ku_id = KuUser.where(id: UsersProgram.where(:program_id => @program.id).uniq.pluck(:ku_user_id)).pluck(:ku_id).first
      Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
      query = Chef::Search::Query.new
      nodes = query.search('node', 'name:' + ku_id).first rescue []
      node = nodes.first
      begin
        download = open("http://" + node.ec2.public_hostname + ":8080/sharedfile/" + file_name)
      rescue
        error = true
      end
      if !error
        IO.copy_stream(download, file_full_path)
      end
    end

    def test_generate_chef_resource
      File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/install_programs.rb", 'w') do |f|
        @program.chef_resources.where(status: "install").each do |chef_resource|
          f.write(ResourceGenerator.resource(chef_resource, @program))
        end
      end

      File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/uninstall_programs.rb", 'w') do |f|
        @program.chef_resources.where(resource_type: "Source", status: "install").each do |chef_resource|
          f.write(ResourceGenerator.uninstall_resource(chef_resource, @program))
        end

        @program.chef_resources.where(status: "install").where.not(resource_type: "Source").each do |chef_resource|
          f.write(ResourceGenerator.uninstall_resource(chef_resource, @program))
        end
      end

      remove_resources = @program.chef_resources.where.not(status: "install")
      File.open("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/recipes/remove_disuse_resources.rb", 'w') do |f|
        remove_resources.where(resource_type: "Source").each do |remove_resource|
          f.write(ResourceGenerator.remove_disuse_resource(remove_resource, @program))
        end

        remove_resources.where.not(resource_type: "Source").each do |remove_resource|
          f.write(ResourceGenerator.remove_disuse_resource(remove_resource, @program))
        end
      end

    end
end
