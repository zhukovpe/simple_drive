require 'rails_helper'

RSpec.describe 'POST /v1/blobs', type: :request do
  subject(:perform_request) { post '/v1/blobs', params: payload, headers: req_headers }

  let(:auth_token) { 'beea30fc-7241-4d23-a043-c640a6b5b322' }
  let(:req_headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'Authorization' => "Bearer #{auth_token}"
    }
  end

  before { allow(Storage.config).to receive(:auth_token).and_return(auth_token) }

  context 'with cloud storage' do
    before do
      allow(Storage.config).to receive(:storage_type).and_return('cloud')
    end

    context 'without id' do
      let(:payload) { {data: 'test_data'}.to_json }

      specify do
        perform_request
        expect(response.status).to eq(400)
      end
    end

    context 'without data' do
      let(:payload) { {id: '56a685b4'}.to_json }

      specify do
        perform_request
        expect(response.status).to eq(400)
      end
    end

    context 'with id & plain data' do
      let(:payload) { {id: '56a685b4', data: 'test_data'}.to_json }

      specify do
        perform_request
        expect(response.status).to eq(400)
      end
    end

    context 'with id & base64 encoded data' do
      let(:payload) { {id: '56a685b4', data: 'SGVsbG8gU2ltcGxlIFN0b3JhZ2UgV29ybGQh'}.to_json }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('54d29457-b9ef-48fd-9f4e-4f8f2fe40786')
      end

      around do |example|
        VCR.use_cassette('blobs') { example.run }
      end

      specify do
        post '/v1/blobs', params: payload, headers: req_headers
        expect(response.status).to eq(200)
      end

      context 'without json header' do
        let(:req_headers) { { 'Authorization' => "Bearer #{auth_token}" } }

        specify do
          perform_request
          expect(response.status).to eq(400)
        end
      end

      context 'without auth token header' do
        let(:req_headers) { { 'CONTENT_TYPE' => 'application/json' } }

        specify do
          perform_request
          expect(response.status).to eq(401)
        end
      end

      context 'with existing id' do
        before do
          StorageInfo.create!(
            identifier: '56a685b4',
            storage_type: 'cloud',
            key: '54d29457-b9ef-48fd-9f4e-4f8f2fe40786'
          )
        end

        specify do
          perform_request
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Id must be unique' })
        end
      end
    end
  end

  context 'with database storage' do
    before do
      allow(Storage.config).to receive(:storage_type).and_return('database')
    end

    context 'with id & base64 encoded data' do
      let(:payload) { {id: '56a685b4', data: 'SGVsbG8gcmVsYXRpb25hbCBkYXRhYmFzZSE='}.to_json }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('4f8f2fe40786')
      end

      specify do
        post '/v1/blobs', params: payload, headers: req_headers
        expect(response.status).to eq(200)
        storage_data = StorageData.find_by(key: '4f8f2fe40786')
        expect(storage_data.blob).to eq('Hello relational database!')
      end
    end
  end

  context 'with local storage' do
    before do
      allow(Storage.config).to receive(:storage_type).and_return('local')
    end

    context 'with id & base64 encoded data' do
      let(:payload) { {id: '56a685b4', data: 'SGVsbG8gZmlsZXN5c3RlbSE='}.to_json }
      let(:file_path) { File.join(Storage.config.storage_dir, 'a07a7731-6977-49d5-9bba-dad47ba36e89') }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('a07a7731-6977-49d5-9bba-dad47ba36e89')
      end

      after { File.delete(file_path) if File.exist?(file_path) }

      specify do
        post '/v1/blobs', params: payload, headers: req_headers
        expect(response.status).to eq(200)
        expect(File.exist?(file_path))
        expect(File.read(file_path)).to eq('Hello filesystem!')
      end
    end
  end

  context 'with ftp storage' do
    before do
      allow(Storage.config).to receive(:storage_type).and_return('ftp')
    end

    context 'with id & base64 encoded data' do
      let(:payload) { {id: '56a685b4', data: 'RlRQIGZpbGUgY29udGVudA=='}.to_json }
      let(:sftp) { double('sftp') }

      before do
        allow(SecureRandom).to receive(:uuid).and_return('test_file_name')
        allow(Net::SFTP).to receive(:start).and_yield(sftp)
      end

      specify do
        expect(sftp).to receive(:upload!).with(instance_of(StringIO), 'test_file_name')
          .and_return(true)
        post '/v1/blobs', params: payload, headers: req_headers
        expect(response.status).to eq(200)
      end
    end
  end
end
