# frozen_string_literal: true
require 'net/http'

module Storage
  class Cloud
    attr_reader :bucket_name, :auth_key, :aws_credentials, :account_id

    CONTENT_TYPE = 'application/octet-stream'

    def initialize
      @bucket_name = ENV['SIMPLE_DRIVE_S3_BUCKET']
      @account_id = ENV['SIMPLE_DRIVE_AWS_ACCOUNT_ID']
      @auth_key = ENV['SIMPLE_DRIVE_AWS_KEY']
      @aws_credentials = AWSCredentials.new(ENV['SIMPLE_DRIVE_S3_REGION'], ENV['SIMPLE_DRIVE_AWS_SECRET'])
    end

    def save(file_name, blob)
      uri = build_uri(file_name)
      req = Net::HTTP::Put.new(uri)
      response = perform_request(req, blob)
      response.code == '200'
    end

    def load(file_name)
      uri = build_uri(file_name)
      req = Net::HTTP::Get.new(uri)
      response = perform_request(req, '')

      if response.code == '200'
        response.read_body
      else
        raise Storage::Error
      end
    end

    private

    def perform_request(request, payload)
      payload ||= ''
      request.body = payload
      request['x-amz-content-sha256'] = Digest::SHA256.new.hexdigest(payload)
      request['x-amz-date'] = aws_credentials.formatted_date
      request['Authorization'] = authorization_header(request.method, request.uri.path, request.to_hash, payload)

      Net::HTTP.start(request.uri.hostname) { |http| http.request(request) }
    end

    def build_uri(file_name)
      uri = URI("https://#{bucket_name}.s3.amazonaws.com")
      uri.path = '/' + file_name
      uri
    end

    def authorization_header(method, path, headers, payload)
      "AWS4-HMAC-SHA256 Credential=#{auth_key}/#{aws_credentials.scope}," +
        "SignedHeaders=#{aws_credentials.signed_headers(headers)}," +
        "Signature=#{aws_credentials.signature(method, path, headers, payload)}"
    end
  end
end
