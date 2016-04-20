json.array!(@user_cookbook_files) do |user_cookbook_file|
  json.extract! user_cookbook_file, :id
  json.url user_cookbook_file_url(user_cookbook_file, format: :json)
end
