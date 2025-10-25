# frozen_string_literal: true
class StoreBlobAction
  attr_reader :storage

  def initialize
    @storage = Storage::Builder.build(storage_type)
  end

  def self.call(identifier, blob) = new.call(identifier, blob)

  def call(identifier, blob)
    StorageInfo.transaction do
      storage_info = StorageInfo.create(identifier:, storage_type:)
      storage.save(storage_info.key, blob)
    end
  end

  private

  def storage_type
    ENV['SIMPLE_DRIVE_STORAGE_TYPE'] || Storage::DEFAULT_TYPE
  end
end
