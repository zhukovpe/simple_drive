require 'rails_helper'

RSpec.describe 'GET /v1/blobs/:id', type: :request do
  let(:auth_token) { 'beea30fc-7241-4d23-a043-c640a6b5b322' }
  let(:req_headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'Authorization' => "Bearer #{auth_token}"
    }
  end
  let(:identifier) { '56a685b4' }
  let(:test_data) { 'Hello Simple Storage World!' }
  let(:encoded_data) { Base64.strict_encode64(test_data) }

  before { allow(Storage.config).to receive(:auth_token).and_return(auth_token) }

  shared_examples 'correct response' do
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
  end

  context 'with valid id' do
    context 'with cloud storage type' do
      before do
        allow(Storage.config).to receive(:storage_type).and_return('cloud')

        StorageInfo.create!(
          identifier: identifier,
          storage_type: 'cloud',
          key: '54d29457-b9ef-48fd-9f4e-4f8f2fe40786'
        )
      end

      around do |example|
        VCR.use_cassette('blobs') { example.run }
      end

      it_behaves_like 'correct response'
    end

    context 'with ftp storage type' do
      class SFTPMock
        def download!(file_name, io)
          io << 'Hello Simple Storage World!'
        end
      end

      let(:sftp) { SFTPMock.new }

      before do
        allow(Storage.config).to receive(:storage_type).and_return('ftp')
        allow(Net::SFTP).to receive(:start).and_yield(sftp)

        StorageInfo.create!(
          identifier: identifier,
          storage_type: 'ftp',
          key: '54d29457-b9ef-48fd-9f4e-4f8f2fe40786'
        )
      end

      it_behaves_like 'correct response'
    end

    context 'with database storage type' do
      before do
        allow(Storage.config).to receive(:storage_type).and_return('database')

        StorageInfo.create!(
          identifier: identifier,
          storage_type: 'database',
          key: '54d29457-b9ef-48fd-9f4e-4f8f2fe40786'
        )

        StorageData.create!(key: '54d29457-b9ef-48fd-9f4e-4f8f2fe40786', blob: test_data)
      end

      it_behaves_like 'correct response'
    end

    context 'with local storage type' do
      let(:file_path) { File.join(Storage.config.storage_dir, 'simple_drive_test') }

      before do
        allow(Storage.config).to receive(:storage_type).and_return('local')
        File.write(file_path, test_data)

        StorageInfo.create!(
          identifier: identifier,
          storage_type: 'local',
          key: 'simple_drive_test'
        )
      end

      after { File.delete(file_path) }

      it_behaves_like 'correct response'
    end

    context 'without auth token header' do
      let(:req_headers) { { 'CONTENT_TYPE' => 'application/json' } }

      specify do
        get "/v1/blobs/#{identifier}", headers: req_headers
        expect(response.status).to eq(401)
        expect(response.body).to be_empty
      end
    end
  end

  context 'with non-existent id' do
    let(:identifier) { 'non_existent_id' }

    specify do
      get "/v1/blobs/#{identifier}", headers: req_headers
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({'error' => "File with id #{identifier} not found"})
    end
  end
end
