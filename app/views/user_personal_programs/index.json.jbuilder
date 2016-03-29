json.array!(@user_personal_programs) do |user_personal_program|
  json.extract! user_personal_program, :id, :ku_user_id, :personal_program_id, :status
  json.url user_personal_program_url(user_personal_program, format: :json)
end
