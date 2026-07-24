class Members::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters
  layout "whole_page"
  before_action :skip_authorization

  def new
    raise ActionController::RoutingError.new("Not Found")
  end

  def create
    raise ActionController::RoutingError.new("Not Found")
  end

  def edit
    if resource.community_id != @community.id
      raise ActionController::RoutingError.new("Not Found")
    end

    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [ :name ])
  end
end
