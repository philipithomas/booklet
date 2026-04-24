# frozen_string_literal: true

class Members::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  after_action :remove_flash, only: [ :create ]
  before_action :skip_authorization
  before_action :check_signups_open
  prepend_before_action :protect_from_spam, only: [ :create ]
  layout "whole_page"

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  def remove_flash
    flash.delete(:notice)
    flash[:notice] = "Now, sign in with that email."
  end

  def build_resource(*args)
    super
    resource.community = @community
    resource.source = "public_join"
  end

  def after_inactive_sign_up_path_for(resource)
    new_member_session_path
  end

  def check_signups_open
    unless @community.signups_open?
      flash[:alert] = I18n.t("devise.registrations.closed")
      redirect_to posts_path and return
    end
  end
end
