json.array!(@chef_resources) do |chef_resource|
  json.extract! chef_resource, :id, :resource_type
  json.url chef_resource_url(chef_resource, format: :json)
end
