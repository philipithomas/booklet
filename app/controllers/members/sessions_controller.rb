# frozen_string_literal: true

class Members::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable
  layout "whole_page"

  before_action :set_community!
  before_action :validate_community_id, only: [ :create ]
  before_action :skip_authorization
  prepend_before_action :protect_from_spam, only: [ :create ]

  def create
    email = params[:member][:email].to_s.strip.downcase
    @member = @community.members.find_by("lower(email) = ?", email)
    if @member.blank?
      flash[:alert] = I18n.t("devise.failure.not_found_in_database")
      return redirect_to new_member_session_path, status: :see_other
    end

    if @member.access_locked?
      flash[:alert] = I18n.t("devise.failure.locked")
      redirect_to new_member_session_path and return
    end

    if params[:member][:password].present?
      handle_code_verification
    else
      generate_and_send_code
    end
  end

  private

  def validate_community_id
    if params[:member].blank? || params[:member][:community_id] != @community.id.to_s
      raise ActiveRecord::RecordNotFound
    end
  end

  def handle_code_verification
    pin = if Rails.env.development? && params[:member][:password].strip == "000000"
      @member.pins.new(code: "000000", expires_at: 1.minute.from_now) # Mock a valid pin in development
    else
      @member.pins.find_by(code: params[:member][:password].strip, expires_at: Time.current..)
    end

    if pin.blank?
      flash.now[:alert] = I18n.t("devise.sessions.incorrect_code")
      render :create, status: :unauthorized and return
    end

    pin.destroy

    if !@member.confirmed?
      if @member.invited_to_sign_up?
        @member.invite! do |m|
          m.skip_invitation = true
        end
        return redirect_to accept_member_invitation_path(invitation_token: @member.raw_invitation_token), status: :see_other
      end

      @member.confirm
    end

    if @member.encrypted_password.blank?
      generated_password = Devise.friendly_token.first(8)
      @member.password = generated_password
      @member.save
    end

    @member.remember_me!
    ahoy.authenticate(@member)
    flash[:alert] = I18n.t("devise.sessions.signed_in")
    remember_me @member
    sign_in(@member, event: :authentication, remember_me: true)
    redirect_to after_sign_in_path_for(@member)
  end

  def generate_and_send_code
    @member.send_login_pin
    render :create, status: :created
  end

  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)

    if stored_location&.start_with?("/sign-in", "/switch/", "/passwordless/")
      "/"
    else
      stored_location || super
    end
  end
end
