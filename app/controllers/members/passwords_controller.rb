# frozen_string_literal: true

class Members::PasswordsController < Devise::PasswordsController
  layout "whole_page"
  before_action :validate_community_id, only: [ :create, :update ]
  before_action :skip_authorization

  def create
    self.resource = resource_class.find_or_initialize_with_errors(
      resource_class.reset_password_keys,
      resource_params,
      :not_found
    )

    if resource.persisted? && resource.invitation_token.present? && !resource.confirmed_at
      resource.invite!
      set_flash_message! :notice, :send_instructions
      respond_with resource, location: new_member_session_path
    else
      super
    end
  end

  protected

  def after_sign_in_path_for(resource)
    posts_path
  end

  def validate_community_id
    if params[:member][:community_id] != @community.id.to_s
      raise ActiveRecord::RecordNotFound
    end
  end
end
