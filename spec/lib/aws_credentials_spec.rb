require 'rails_helper'

# Examples here does not use real keys and are a copy-paste from the guide
# https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
RSpec.describe AWSCredentials do
  let(:region) { 'us-east-1' }
  let(:key_id) { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:date_string) { 'Fri, 24 May 2013 00:00:00 GMT' }
  let(:timestamp) { '20130524T000000Z' }
  let(:bucket_name) { 'examplebucket' }
  let(:payload) { 'Welcome to Amazon S3.' }
  let(:http_method) { 'PUT' }
  let(:uri) { '/test%24file.text' }
  let(:headers) do
    {
      'date' => ['Fri, 24 May 2013 00:00:00 GMT'],
      'host' => ['examplebucket.s3.amazonaws.com'],
      'x-amz-content-sha256' => ['44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072'],
      'x-amz-date' => ['20130524T000000Z'],
      'x-amz-storage-class' => ['REDUCED_REDUNDANCY']
    }
  end

  describe '#canonical_request' do
    subject(:canonical_request) do
      AWSCredentials.new(region, secret_access_key).canonical_request(http_method, uri, headers, payload)
    end

    specify do
      expect(canonical_request).to eq(<<~SAMPLE.chomp)
        PUT
        /test%24file.text

        date:Fri, 24 May 2013 00:00:00 GMT
        host:examplebucket.s3.amazonaws.com
        x-amz-content-sha256:44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072
        x-amz-date:20130524T000000Z
        x-amz-storage-class:REDUCED_REDUNDANCY

        date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class
        44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072
      SAMPLE
    end
  end

  describe '#string_to_sign' do
    subject(:string_to_sign) do
      AWSCredentials.new(region, secret_access_key, Time.parse(date_string))
        .string_to_sign(http_method, uri, headers, payload)
    end

    specify do
      expect(string_to_sign).to eq(<<~SAMPLE.chomp)
        AWS4-HMAC-SHA256
        20130524T000000Z
        20130524/us-east-1/s3/aws4_request
        9e0e90d9c76de8fa5b200d8c849cd5b8dc7a3be3951ddb7f6a76b4158342019d
      SAMPLE
    end
  end

  describe '#signature' do
    subject(:signature) do
      AWSCredentials.new(region, secret_access_key, Time.parse(date_string))
        .signature(http_method, uri, headers, payload)
    end

    specify do
      expect(signature).to eq('98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd')
    end
  end
end
