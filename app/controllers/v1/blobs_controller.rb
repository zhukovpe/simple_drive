module V1
  class BlobsController < ApplicationController
    before_action :authenticate!

    def create
      identifier = params.require(:id)
      input_data = params.require(:data)
      decoded_data = Base64.strict_decode64(input_data)
      storage = Storage::Builder.build(storage_type)

      StorageInfo.transaction do
        storage_info = StorageInfo.create(identifier:, storage_type:)
        storage.save(storage_info.key, decoded_data)
      end

      head :ok
    rescue ArgumentError => e
      head :bad_request
    rescue ActiveRecord::RecordNotUnique => e
      render(status: 400, json: { error: 'Id must be unique' })
    end

    def show
      identifier = params.require(:id)
      storage_info = StorageInfo.find_by!(identifier: identifier)
      storage = Storage::Builder.build(storage_info.storage_type)
      blob = storage.load(storage_info.key)

      blob_hash = {
        id: identifier,
        data: Base64.strict_encode64(blob),
        size: blob.size,
        created_at: storage_info.created_at
      }

      render json: blob_hash
    rescue ActiveRecord::RecordNotFound => e
      render(status: 404, json: { error: "File with id #{identifier} not found" })
    end

    private

    def authenticate!
      token = request.headers['Authorization']&.split(' ')&.last

      if token.blank? || token != Storage.config.auth_token
        head :unauthorized
      end
    end

    def storage_type = Storage.config.storage_type
  end
end
