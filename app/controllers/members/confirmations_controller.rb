# frozen_string_literal: true

class Members::ConfirmationsController < Devise::ConfirmationsController
  layout "whole_page"
  before_action :validate_community_id, only: [ :create ]
  before_action :skip_authorization

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end

  protected

  def validate_community_id
    if params[:member][:community_id] != @community.id.to_s
      raise ActiveRecord::RecordNotFound
    end
  end

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    posts_path
  end
end
