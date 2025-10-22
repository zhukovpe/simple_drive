module V1
  class BlobsController < ApplicationController
    def create
      identifier = params.require(:id)
      input_data = params.require(:data)
      decoded_data = Base64.decode64(input_data)

      head :ok
    rescue StandardError => e
      head 400
    end
  end
end
