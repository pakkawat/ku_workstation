json.array!(@chef_values) do |chef_value|
  json.extract! chef_value, :id, :chef_attribute_id, :ku_user_id, :value
  json.url chef_value_url(chef_value, format: :json)
end
