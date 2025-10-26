# frozen_string_literal: true
require_relative 'storage/builder'
require_relative 'storage/cloud'
require_relative 'storage/config'
require_relative 'storage/database'
require_relative 'storage/error'
require_relative 'storage/local'

module Storage
  AVAILABLE_TYPES = %w(cloud database local ftp)
  DEFAULT_TYPE = 'database'

  cattr_reader :config, default: Storage::Config.new
end
