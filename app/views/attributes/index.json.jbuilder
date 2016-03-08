json.array!(@attributes) do |attribute|
  json.extract! attribute, :id, :name, :chef_property_id
  json.url attribute_url(attribute, format: :json)
end
