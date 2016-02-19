module ProgramsHelper
  def expand_collapse_for(chef_resource, program)
    render html: ExpandCollapse.new(chef_resource, program).html
  end

  class ExpandCollapse
    def initialize(chef_resource, program)
      @chef_resource = chef_resource
      @program = program
    end

    def html
      case @chef_resource.resource_type
      when "Repository"
        repository
      when "Deb"
        deb
      when "Source"
        source
      when "Download"
        download
      when "Extract"
        extract
      when "Config_file"
        config_file
      when "Copy_file"
        conpy_file
      end
    end

    def repository
      str_temp = ""
      @chef_resource.chef_properties.each do |property|
        str_temp += "<div class='form-group'>"
        str_temp += "  <label for='name'>"
        str_temp += "    Program name:"
        str_temp += "  </label>"
        str_temp += "  <div class='input-group'>"
        str_temp += "    <span class='input-group-addon'>"
        str_temp += "      <span class='glyphicon glyphicon-book'>"
        str_temp += "      </span>"
        str_temp += "    </span>"
        str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
        str_temp += "  </div>"
        str_temp += "</div>"
      end
      return str_temp.html_safe
    end

    def deb
      str_temp = ""
      @chef_resource.chef_properties.each do |property|
        if property.value_type == "program_name"
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Program name:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-book'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        else #source
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Source file:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-file'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        end
      end
      return str_temp.html_safe
    end

    def source
      str_temp = ""
      @chef_resource.chef_properties.each do |property|
        if property.value_type == "program_name"
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Program name:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-book'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        else #source_file
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Source file:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-file'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        end
      end
      return str_temp.html_safe
    end

    def download
      str_temp = ""
      @chef_resource.chef_properties.each do |property|
        if property.value_type == "download_url"
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Download url:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-save-file'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        else #source_file
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Source file:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-file'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        end
      end
      return str_temp.html_safe
    end

    def extract
      str_temp = ""
      @chef_resource.chef_properties.each do |property|
        if property.value_type == "source_file"
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Source file:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-save-file'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        else #extract_to
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Extract to:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-folder-open'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        end
      end
      return str_temp.html_safe
    end

    def config_file
      str_temp = ""
      @chef_resource.chef_properties.each do |property|
        str_temp += "<div class='form-group'>"
        str_temp += "  <label for='name'>"
        str_temp += "    File path:"
        str_temp += "  </label>"
        str_temp += "  <div class='input-group'>"
        str_temp += "    <span class='input-group-addon'>"
        str_temp += "      <span class='glyphicon glyphicon-file'>"
        str_temp += "      </span>"
        str_temp += "    </span>"
        str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
        str_temp += "  </div>"
        str_temp += "</div>"
        file_name = File.basename(property.value)
        if File.exists?("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb")
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    File status:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <img src='/assets/running.png' alt='Running'>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' value='#{file_name}' class='form-control' disabled='disabled'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        else
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    File status:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <img src='/assets/error.png' alt='error'>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' value='File not found' class='form-control' disabled='disabled'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        end

      end
      return str_temp.html_safe
    end

    def copy_file
      str_temp = ""
      @chef_resource.chef_properties.each do |property|
        if property.value_type == "copy_type"
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Copy:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-list-alt'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          if property.value == "file"
            str_temp += "    <select class='form-control'><option value='file' selected>File</option><option value='folder'>Folder</option></select>"
          else
            str_temp += "    <select class='form-control'><option value='file'>File</option><option value='folder' selected>Folder</option></select>"
          end
          str_temp += "  </div>"
          str_temp += "</div>"
        elsif property.value_type == "source_file"
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Source:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-file'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        else #destination_file
          str_temp += "<div class='form-group'>"
          str_temp += "  <label for='name'>"
          str_temp += "    Destination:"
          str_temp += "  </label>"
          str_temp += "  <div class='input-group'>"
          str_temp += "    <span class='input-group-addon'>"
          str_temp += "      <span class='glyphicon glyphicon-file'>"
          str_temp += "      </span>"
          str_temp += "    </span>"
          str_temp += "    <input type='text' name='chef_property_#{property.id}' value='#{property.value}' class='form-control'>"
          str_temp += "  </div>"
          str_temp += "</div>"
        end
      end
      return str_temp.html_safe
    end

  end

  def resource_type_full_name(resource_type)
    case resource_type
    when "Repository"
      return "Install from repository"
    when "Deb"
      return "Install from deb file"
    when "Source"
      return "Install from source"
    when "Download"
      return "Download file"
    when "Extract"
      return "Extract file"
    when "Config_file"
      return "Config file"
    when "Copy_file"
      return "Copy file"
    end
  end


end
