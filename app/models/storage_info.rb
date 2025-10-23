# frozen_string_literal: true
class StorageInfo < ApplicationRecord
  validates :storage_type, :identifier, presence: true
  validates :storage_type, inclusion: { in: Storage::AVAILABLE_TYPES }
end
