# frozen_string_literal: true
class StorageInfo < ApplicationRecord
  validates :storage_type, :identifier, presence: true
  validates :storage_type, inclusion: { in: Storage::AVAILABLE_TYPES }

  before_validation :ensure_key_has_value

  private

  def ensure_key_has_value
    self.key ||= SecureRandom.uuid
  end
end
