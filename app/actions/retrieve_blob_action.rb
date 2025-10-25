class RetrieveBlobAction
  def self.call(identifier) = new.call(identifier)

  def call(identifier)
    storage_info = StorageInfo.find_by!(identifier: identifier)
    storage = Storage::Builder.build(storage_info.storage_type)
    blob = storage.load(storage_info.key)

    {
      id: identifier,
      data: Base64.strict_encode64(blob),
      size: blob.size,
      created_at: storage_info.created_at
    }
  end
end
