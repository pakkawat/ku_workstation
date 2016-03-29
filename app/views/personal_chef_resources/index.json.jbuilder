json.array!(@personal_chef_resources) do |personal_chef_resource|
  json.extract! personal_chef_resource, :id, :resource_type, :priority
  json.url personal_chef_resource_url(personal_chef_resource, format: :json)
end
