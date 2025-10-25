# frozen_string_literal: true
require 'openssl'
# https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
class AWSCredentials
  attr_reader :current_date, :region, :secret_access_key

  def initialize(region, secret_access_key, date = Time.current)
    @region = region
    @secret_access_key = secret_access_key
    @current_date = date
  end

  def signature(http_method, uri, headers, payload)
    OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign(http_method, uri, headers, payload))
  end

  def signing_key
    date_key = hmac_sha256('AWS4' + secret_access_key, formatted_short_date)
    date_region_key = hmac_sha256(date_key, region)
    date_region_service_key = hmac_sha256(date_region_key, 's3')
    hmac_sha256(date_region_service_key, 'aws4_request')
  end

  def string_to_sign(http_method, uri, headers, payload)
    'AWS4-HMAC-SHA256' + "\n" + formatted_date + "\n" + scope + "\n" +
      Digest::SHA256.new.hexdigest(canonical_request(http_method, uri, headers, payload))
  end

  def scope
    formatted_short_date + '/' + region + '/s3/aws4_request'
  end

  def canonical_request(http_method, uri, headers, payload)
    http_method + "\n" +
      uri + "\n" +
      "\n" + # empty line for query params
      canonical_headers(headers) + "\n" +
      signed_headers(headers) + "\n" +
      hashed_payload(payload)
  end

  def canonical_headers(headers_hash)
    headers_arr = headers_hash.transform_keys!(&:to_s).sort
    headers_arr.reduce('') do |memo, header|
      memo += header[0].downcase + ':' + header[1].first.to_s.strip + "\n"
    end
  end

  def signed_headers(headers_hash)
    headers_hash.keys.map(&:to_s).sort.join(';')
  end

  def hashed_payload(payload)
    payload ||= ''
    Digest::SHA256.new.hexdigest(payload)
  end

  def hmac_sha256(key, value)
    OpenSSL::HMAC.digest('sha256', key, value)
  end

  def formatted_date = current_date.utc.strftime('%Y%m%dT%H%M%SZ')
  def formatted_short_date = current_date.utc.strftime('%Y%m%d')
end
