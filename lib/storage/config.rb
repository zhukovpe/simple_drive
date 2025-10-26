module Storage
  class Config
    attr_writer :storage_type, :storage_dir

    def storage_type
      @storage_type ||= ENV['SIMPLE_DRIVE_STORAGE_TYPE'] || Storage::DEFAULT_TYPE
    end

    def storage_dir
      @storage_dir ||= ENV['SIMPLE_DRIVE_STORAGE_DIR'] || File.join(Rails.root, 'tmp')
    end

    def auth_token
      ENV['SIMPLE_DRIVE_AUTH_TOKEN']
    end
  end
end
