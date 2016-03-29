json.array!(@personal_programs) do |personal_program|
  json.extract! personal_program, :id, :program_name, :note
  json.url personal_program_url(personal_program, format: :json)
end
