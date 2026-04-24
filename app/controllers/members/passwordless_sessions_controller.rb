# controllers/members/passwordless_sessions_controller.rb
class Members::PasswordlessSessionsController < ApplicationController
  before_action :set_community!
  layout "whole_page"

  def show
    begin
      member = Member.find_by_passwordless_signed_id!(params[:id])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = I18n.t("devise.passwordless.sessions.show.alert")
      redirect_to new_member_session_path and return
    end

    if member.access_locked?
      flash[:alert] = I18n.t("devise.passwordless.sessions.show.alert")
      redirect_to new_member_session_path and return
    end

    raise "Community mismatch" if member.community != @community

    ahoy.authenticate(member)
    member.remember_me!
    flash[:notice] = I18n.t("devise.passwordless.sessions.show.notice")

    sign_in_and_redirect(member, event: :authentication)
  end
end
