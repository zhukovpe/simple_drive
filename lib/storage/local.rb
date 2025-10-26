module Storage
  class Local
    def save(file_name, blob)
      directory = make_dir(storage_dir)
      full_path = ::File.join(directory, file_name)

      File.open(full_path, 'wb') do |file|
        file.write(blob)
      end
    end

    def load(file_name)
      full_path = File.join(storage_dir, file_name)
      File.read(full_path)
    end

    private

    def storage_dir = Storage.config.storage_dir

    def make_dir(path)
      return path if File.directory?(path)

      FileUtils.mkdir_p(path)
    end
  end
end
