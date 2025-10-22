module V1
  class BlobsController < ApplicationController
    def create
      identifier = params.require(:id)
      input_data = params.require(:data)
      decoded_data = Base64.strict_decode64(input_data)

      head :ok
    rescue ArgumentError => e
      head 400
    end
  end
end
