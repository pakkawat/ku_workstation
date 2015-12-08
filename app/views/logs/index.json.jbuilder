json.array!(@logs) do |log|
  json.extract! log, :id, :LogPath, :Error
  json.url log_url(log, format: :json)
end
