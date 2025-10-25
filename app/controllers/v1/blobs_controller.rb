module V1
  class BlobsController < ApplicationController
    def create
      identifier = params.require(:id)
      input_data = params.require(:data)
      decoded_data = Base64.strict_decode64(input_data)
      StoreBlobAction.call(identifier, decoded_data)

      head :ok
    rescue ArgumentError => e
      head 400
    end

    def show
      identifier = params.require(:id)
      blob_hash = RetrieveBlobAction.call(identifier)

      render json: blob_hash
    end
  end
end
