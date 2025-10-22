require 'rails_helper'

RSpec.describe 'POST /v1/blobs', type: :request do
  let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

  context 'without id' do
    let(:payload) { {data: 'test_data'}.to_json }

    specify do
      post '/v1/blobs', params: payload, headers: json_headers
      expect(response.status).to eq(400)
    end
  end

  context 'without data' do
    let(:payload) { {id: '56a685b4'}.to_json }

    specify do
      post '/v1/blobs', params: payload, headers: json_headers
      expect(response.status).to eq(400)
    end
  end

  context 'with id & plain data' do
    let(:payload) { {id: '56a685b4', data: 'test_data'}.to_json }

    specify do
      post '/v1/blobs', params: payload, headers: json_headers
      expect(response.status).to eq(400)
    end
  end

  context 'with id & base64 encoded data' do
    let(:payload) { {id: '56a685b4', data: 'SGVsbG8gU2ltcGxlIFN0b3JhZ2UgV29ybGQh'}.to_json }

    specify do
      post '/v1/blobs', params: payload, headers: json_headers
      expect(response.status).to eq(200)
    end
  end
end
