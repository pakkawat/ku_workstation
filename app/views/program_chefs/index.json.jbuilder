json.array!(@program_chefs) do |program_chef|
  json.extract! program_chef, :id
  json.url program_chef_url(program_chef, format: :json)
end
