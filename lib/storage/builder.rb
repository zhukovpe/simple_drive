# frozen_string_literal: true
module Storage
  class Builder
    def self.build(storage_type)
      case storage_type
      when 'cloud'
        Storage::Cloud.new
      when 'database'
        Storage::Database.new
      when 'file'
        Storage::File.new
      when 'ftp'
        Storage::FTP.new
      else
        raise ArgumentError.new("Uknown storage type")
      end
    end
  end
end
