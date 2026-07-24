class Communities::Settings::SubscriptionController < CommunitiesController
  layout "settings"
  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def show
    if @community&.payment_processor&.subscribed?
      @portal_session = @community.payment_processor.billing_portal(
        return_url: posts_url(host: @community.host)
      )
      redirect_to @portal_session.url, status: :see_other, allow_other_host: true
    else
      render :show
    end
  end
end
