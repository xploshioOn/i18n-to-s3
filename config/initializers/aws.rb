require 'aws-sdk-s3'
Aws.config.update({
  region: ENV["AWS_REGION_DEFAULT"],
  credentials: Aws::Credentials.new(ENV["AWS_KEY"], ENV["AWS_SECRET"])
})
