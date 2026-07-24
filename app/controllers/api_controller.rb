class APIController < ApplicationController
  before_action :verify_api_key_and_set_community!
  skip_before_action :verify_authenticity_token
  before_action :skip_authorization
  skip_before_action :track_ahoy_visit
  skip_before_action :track_unverified_request
  skip_after_action :track_action
  before_action :set_json_format

  def authenticated_user
    @api_key
  end

  private

  def set_json_format
    request.format = :json
  end

  def verify_api_key_and_set_community!
    external_key = request.headers["api-key"] || request.headers["api_key"]
    if external_key.present?
      @api_key = APIKey.find_by_external_key(external_key)
      if @api_key
        @community = @api_key.community
      else
        render json: { error: "Invalid API key" }, status: :unauthorized
      end
    else
      render json: { error: "API key not present" }, status: :unauthorized
    end
  end
end
