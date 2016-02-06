json.array!(@chef_properties) do |chef_property|
  json.extract! chef_property, :id, :value
  json.url chef_property_url(chef_property, format: :json)
end
