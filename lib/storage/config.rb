module Storage
  class Config
    attr_writer :auth_token, :storage_type, :storage_dir, :s3_bucket_name, :s3_region,
      :aws_key, :aws_secret

    def storage_type
      @storage_type ||= ENV['SIMPLE_DRIVE_STORAGE_TYPE'] || Storage::DEFAULT_TYPE
    end

    def storage_dir
      @storage_dir ||= ENV['SIMPLE_DRIVE_STORAGE_DIR'] || File.join(Rails.root, 'tmp')
    end

    def auth_token = @auth_token ||= ENV['SIMPLE_DRIVE_AUTH_TOKEN']
    def aws_key = @aws_key ||= ENV['SIMPLE_DRIVE_AWS_KEY']
    def aws_secret = @aws_secret ||= ENV['SIMPLE_DRIVE_AWS_SECRET']
    def s3_bucket_name = @s3_bucket_name ||= ENV['SIMPLE_DRIVE_S3_BUCKET']
    def s3_region = @s3_region ||= ENV['SIMPLE_DRIVE_S3_REGION']
  end
end
