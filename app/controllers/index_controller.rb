class IndexController < ApplicationController
  before_action :set_email, only: [ :create ]
  layout "whole_page"

  def index
    if session[:validated_email].present?
      # Email has been validated, render the index page
      render :index
    else
      # No validated email, render the new form to get the email and pin
      render :new
    end
  end

  def create
    email_valid = @email.present? &&
      (Member.exists?(email: @email) ||
       IndexPin.exists?(email: @email) ||
       Truemail.validate(@email).result.success)

    unless email_valid
      flash.now[:alert] = I18n.t("index.failure.invalid_email")
      render :new, status: :unprocessable_entity and return
    end

    pin_code = params[:member][:password].to_s.strip

    if pin_code.present?
      index_pin = IndexPin.find_by(email: @email, code: pin_code, expires_at: Time.current..)
      if index_pin || (Rails.env.development? && pin_code == "000000")
        # Correct pin, sign in the member
        session[:validated_email] = @email
        index_pin&.destroy
        render :index, status: :created and return
      else
        # Incorrect pin, render the new form with an error
        flash.now[:alert] = I18n.t("index.failure.incorrect_pin")
        render :create, status: :unauthorized and return
      end
    else
      # No pin code provided, create a new IndexPin
      @index_pin = IndexPin.create_pin(@email)
      if @index_pin.persisted?
        # TODO: Send the pin to the member's email
        render :create, status: :created and return
      else
        # Failed to create IndexPin, render the new form with an error
        flash.now[:alert] = I18n.t("index.failure.cannot_create_pin")
        render :new, status: :unprocessable_entity and return
      end
    end
  end

  def destroy
    session.delete(:validated_email)
    redirect_to marketing_root_url(host: Rails.configuration.marketing_host.to_s), status: :see_other, allow_other_host: true
  end

  private

  def set_email
    @email = params[:member][:email].to_s.strip.downcase
  end
end
