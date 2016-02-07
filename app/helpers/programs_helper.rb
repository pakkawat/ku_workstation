module ProgramsHelper
  def expand_collapse_for(chef_resource)
    render html: ExpandCollapse.new(chef_resource).html
  end

  class ExpandCollapse
    def initialize(chef_resource)
      @chef_resource = chef_resource
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
          str_temp += "      <span class='glyphicon glyphicon-save-file'>"
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
  end

end
