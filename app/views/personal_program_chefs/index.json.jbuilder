json.array!(@personal_program_chefs) do |personal_program_chef|
  json.extract! personal_program_chef, :id, :personal_chef_resource_id, :personal_program_id
  json.url personal_program_chef_url(personal_program_chef, format: :json)
end
