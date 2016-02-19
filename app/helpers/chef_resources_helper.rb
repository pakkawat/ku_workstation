module ChefResourcesHelper

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
    when "Create_file"
      return "Create file"
    end
  end

end
