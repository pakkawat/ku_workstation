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
    end
  end

end
