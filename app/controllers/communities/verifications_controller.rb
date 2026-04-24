class Communities::VerificationsController < CommunitiesController
  before_action -> { authorize @community, policy_class: VerificationPolicy }
  layout "whole_page"

  def index
    if current_member.identity_verified?
      redirect_to member_path(current_member), notice: I18n.t("communities.verifications.flash.verified")
    elsif params[:stripe_return] == "1"
      render :index
    else
      redirect_to current_member.verification_url(return_url: verifications_url(host: @community.host, stripe_return: 1)), status: :see_other, allow_other_host: true
    end
  end
end
