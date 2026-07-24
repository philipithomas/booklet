class Communities::Settings::BillingController < CommunitiesController
  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def show
    if @community&.payment_processor&.subscribed?
      redirect_to billing_portal_url, status: :see_other, allow_other_host: true
    else
      redirect_to @community.checkout_url(
        settings_confirmation_url(host: @community.host),
        settings_subscription_url(host: @community.host)
      ), status: :see_other, allow_other_host: true
    end
  end

  private

  def billing_portal_url
    @portal_session = @community.payment_processor.billing_portal(
      return_url: posts_url(host: @community.host)
    )
    redirect_to @portal_session.url, status: :see_other, allow_other_host: true
  end
end
