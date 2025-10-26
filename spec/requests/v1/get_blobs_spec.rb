require 'rails_helper'

RSpec.describe 'GET /v1/blobs/:id', type: :request do
  let(:auth_token) { 'beea30fc-7241-4d23-a043-c640a6b5b322' }
  let(:req_headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'Authorization' => "Bearer #{auth_token}"
    }
  end

  before { allow(Storage.config).to receive(:auth_token).and_return(auth_token) }

  context 'with valid id' do
    let(:identifier) { '56a685b4' }
    let(:test_data) { 'Hello Simple Storage World!' }
    let(:encoded_data) { Base64.strict_encode64(test_data) }

    before do
      storage_info = StorageInfo.create!(
        identifier: identifier,
        storage_type: 'cloud',
        key: '54d29457-b9ef-48fd-9f4e-4f8f2fe40786'
      )
    end

    around do |example|
      VCR.use_cassette('blobs') do
        example.run
      end
    end

    specify do
      get "/v1/blobs/#{identifier}", headers: req_headers

      expect(response.status).to eq(200)
      expect(response.content_type).to include('application/json')

      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(identifier)
      expect(json_response['data']).to eq(encoded_data)
      expect(json_response['size']).to eq(test_data.size)
      expect(json_response['created_at']).to be_present
    end

    context 'without auth token header' do
      let(:req_headers) { { 'CONTENT_TYPE' => 'application/json' } }

      specify do
        get "/v1/blobs/#{identifier}", headers: req_headers
        expect(response.status).to eq(401)
      end
    end
  end

  context 'with non-existent id' do
    let(:identifier) { 'non_existent_id' }

    specify do
      get "/v1/blobs/#{identifier}", headers: req_headers
      expect(response.status).to eq(404)
    end
  end
end
