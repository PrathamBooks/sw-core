class Api::V1::ConfirmationsController < Devise::ConfirmationsController
  respond_to :json
end