class SwitchController < ApplicationController
  def index
    raise ActionController::RoutingError.new("Not Found") if validated_email.blank?
    @other_memberships = Member.where(email: validated_email, locked_at: nil).where.not(id: current_member&.id).includes(:community).order(created_at: :desc)
  end

  def show
    raise ActionController::RoutingError.new("Not Found") if validated_email.blank?

    new_member = Community.find(params[:slug]).members.find_by(email: validated_email, locked_at: nil)

    redirect_to sign_in_url(new_member), status: :see_other, allow_other_host: true
  end

  private

  def validated_email
    if current_member&.confirmed_at? && member_signed_in?
      current_member.email
    elsif session[:validated_email].present?
      session[:validated_email]
    end
  end

  def sign_in_url(member)
    if !member.confirmed?
      if member.invited_to_sign_up?
        member.invite! do |m|
          m.skip_invitation = true
        end
        return accept_member_invitation_url(invitation_token: member.raw_invitation_token, host: member.community.host)
      end

      member.confirm
    end

    passwordless_signin_url(member.generate_passwordless_signed_id, host: member.community.host)
  end
end
