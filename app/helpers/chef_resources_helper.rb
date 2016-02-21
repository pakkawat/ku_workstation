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
      return "Edit file"
    when "Copy_file"
      return "Copy file"
    when "Create_file"
      return "Create file"
    when "Move_file"
      return "Move file"
    when "Execute_command"
      return "Execute command"
    end
  end

end
