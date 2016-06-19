Aws.config.update(
  credentials: Aws::Credentials.new(ENV['aws_access_key_id'], ENV['aws_secret_access_key']),
  region: 'ap-southeast-1'
)
