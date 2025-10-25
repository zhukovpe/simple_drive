# frozen_string_literal: true
require_relative 'storage/builder'
require_relative 'storage/cloud'
require_relative 'storage/error'

module Storage
  AVAILABLE_TYPES = %w(cloud database file ftp)
  DEFAULT_TYPE = 'database'
end
