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

    def save(uuid, blob)
      uri = build_uri(uuid)
      req = Net::HTTP::Put.new(uri)
      response = perform_request(req, blob)
    end

    def load(uuid)
      uri = build_uri(uuid)
      req = Net::HTTP::Get.new(uri)
      response = perform_request(req, '')
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

    def build_uri(uuid)
      uri = URI("https://#{bucket_name}.s3.amazonaws.com")
      uri.path = '/' + uuid
      uri
    end

    def authorization_header(method, path, headers, payload)
      "AWS4-HMAC-SHA256 Credential=#{auth_key}/#{aws_credentials.scope}," +
        "SignedHeaders=#{aws_credentials.signed_headers(headers)}," +
        "Signature=#{aws_credentials.signature(method, path, headers, payload)}"
    end
  end
end
