class Communities::PushSubscriptionsController < CommunitiesController
  def create
    authorize PushSubscription
    subscription = current_member.push_subscriptions.find_or_initialize_by(endpoint: params[:endpoint])
    subscription.assign_attributes(
      p256dh: params[:p256dh],
      auth: params[:auth],
      subscribed: true,
      ahoy_visit: current_visit,
      user_agent: request.user_agent
    )
    subscription.save!
    if subscription.persisted?
      render json: { message: "Subscription successfully saved" }, status: :ok
    else
      render json: { error: "Error in storing subscription" }, status: :unprocessable_entity
    end
  end
end
