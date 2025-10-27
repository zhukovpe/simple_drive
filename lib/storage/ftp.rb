require 'net/sftp'
require 'stringio'

module Storage
  class FTP
    def save(file_name, blob)
      file = StringIO.new(blob)
      Net::SFTP.start(ftp_host, ftp_user, password: ftp_password) do |sftp|
        sftp.upload!(file, file_name)
      end
    end

    def load(file_name)
      blob = StringIO.new
      Net::SFTP.start(ftp_host, ftp_user, password: ftp_password) do |sftp|
        sftp.download!(file_name, blob)
      end

      blob.string
    end

    private

    def ftp_host = Storage.config.ftp_host
    def ftp_user = Storage.config.ftp_user
    def ftp_password = Storage.config.ftp_password
  end
end
