module Storage
  class Database
    def save(file_name, blob)
      StorageData.create!(key: file_name, blob: blob)
    end

    def load(file_name)
      StorageData.find_by!(key: file_name)
    end
  end
end
