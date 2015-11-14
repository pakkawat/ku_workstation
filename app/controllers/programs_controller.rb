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
    #chef_attribute = ChefAttribute.new
    #@builder = ActionView::Helpers::FormBuilder.new(:chef_attribute, chef_attribute, view_context, {})
    #2.times{ @program.chef_resources.build }
    #chef_resource.chef_attributes.build
  end

  def create
    update_file_name_to_params
    @program = Program.new(program_params)



    #str_temp = ""
    #str_temp += program_params.to_s+"-----------------------------"
    #if chef_resources_attributes not nil
    

    #str_temp += program_params.to_s
    #render plain: str_temp



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
          generate_new_chef_resource
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
    update_file_name_to_params
    find_differ_resource
    generate_remove_resource
    if @program.update_attributes(program_params)
      generate_new_chef_resource
      flash[:success] = "Program has been updated"
      redirect_to programs_path
    else
      render "edit"
    end
  end

  def destroy# not delete user run_list
    @program = Program.find(params[:id])
    #find_other_delete_resources
    #generate_remove_resource
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

  def update_file_name_to_params
    params[:program][:chef_resources_attributes].each do |key, value|
      #value[:resource_name] = i.to_s
      #i = i+1
      resource_key = key
      if value[:resource_type] == "Zip" || value[:resource_type] == "Deb"
        value[:chef_attributes_attributes].each do |key, value|
          if value[:att_type] == "source"
            url = value[:att_value]
            uri = URI.parse(url)
            params[:program][:chef_resources_attributes][resource_key][:file_name] = File.basename(uri.path)
          end
        end
      end
    end
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
        f.write("include_recipe \'#{program.program_name}::uninstall_programs\'")
        f.write("\n\n")
      end
      FileUtils.mv directory+"/recipes/default.rb", directory+"/recipes/header.rb"
      output = File.open(directory+"/recipes/default.rb", "w")
      output << ""
      output.close
      output = File.open(directory+"/recipes/uninstall_programs.rb","w")
      output << ""
      output.close
      # to_do # upload "knife cookbook upload remove-xxx"
    end

    return check_error

  end

  def generate_new_chef_resource
    File.open("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/recipes/default.rb", 'w') do |f|
      f.write("include_recipe \'#{@program.program_name}::header\'\n\n")
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

  def find_differ_resource
    str_temp = ""
    params[:program][:chef_resources_attributes].each do |key, value|
      if value[:_destroy] == "false"
        str_temp += value.to_s+"---"

        #if value[:id].nil?# new value
          #str_temp += "new[[["+value[:chef_attributes_attributes].to_s+"]]]---"
          #update_new_resource(chef_resource)
        if !value[:id].nil? #chef_resource old value ( if different delete old file)
          str_temp += "old[[["+value[:chef_attributes_attributes].to_s+"]]]---"
          chef_resource_id = value[:id]
          new_resource_name = value[:resource_name]
          value[:chef_attributes_attributes].each do |key, value|
            if value[:_destroy] == "false"
              if !value[:id].nil? #chef_attribute old value ( if different delete old file)
                if value[:att_type] == "source" || value[:att_type] == "extract_path" # zip, deb
                  chef_att = ChefAttribute.find(value[:id])
                  if value[:att_value] != chef_att.att_value
                    add_remove_files(ChefResource.find(chef_resource_id))
                  end
                elsif value[:att_type] == "action" # package
                  chef_re = ChefResource.find(chef_resource_id)
                  if new_resource_name != chef_re.resource_name
                    add_remove_files(chef_re)
                  end
                end
              end # if !value[:id].nil? #chef_attribute old value ( if different delete old file)
            else # chef_attribute has been delete (delete old file and uninstall program)
              add_remove_files(ChefResource.find(chef_resource_id))
            end # if value[:_destroy] == "false"
          end # value[:chef_attributes_attributes].each do |key, value|
        end # if !value[:id].nil?
      else # chef_resource has been deleted (delete old file and uninstall program)
        str_temp += "delete_resource[["+value.to_s+"]]---"
        add_remove_files(ChefResource.find(value[:id]))
      end
    end
    #render plain: str_temp+"||||||||||||"+program_params.inspect
  end

  def add_remove_files(chef_resource)
    if !@program.remove_files.find_by(chef_resource_id: chef_resource.id).present? # check Is chef_resource_id alredy in remove_files
      if ChefAttribute.where("att_type = 'source' AND att_value LIKE (?)","%#{chef_resource.file_name}").count == 1 # check file_name use by this chef_resource only
        chef_resource.chef_attributes.each do |chef_attribute|
          #if chef_attribute.att_type == "source" || chef_attribute.att_type == "extract_path"
          remove_file = RemoveFile.new(program_id: @program.id, chef_resource_id: chef_resource.id, resource_type: chef_resource.resource_type, resource_name: chef_resource.resource_name, att_type: chef_attribute.att_type, att_value: chef_attribute.att_value)
          remove_file.save
        end
      end
    end
  end

  def find_other_delete_resources
    @program.chef_resources.each do |chef_resource|
      add_remove_files(chef_resource)
    end
  end

  def generate_remove_resource
    remove_files = RemoveFile.where(program_id: @program.id)
    File.open("/home/ubuntu/chef-repo/cookbooks/"+@program.program_name+"/recipes/uninstall_programs.rb", 'w') do |f|
      f.write(ResourceGenerator.delete_resources(remove_files))
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
      params.require(:program).permit(:program_name, :note, chef_resources_attributes: [ :id, :resource_name, :resource_type, :file_name, :_destroy, chef_attributes_attributes: [ :id, :att_type, :att_value, :_destroy ] ] )
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
