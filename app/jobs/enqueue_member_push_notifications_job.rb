class EnqueueMemberPushNotificationsJob < ApplicationJob
  queue_as :high

  def perform(member, **)
    member.push_subscriptions.each do |push_subscription|
      DeliverPushNotificationJob.perform_later(push_subscription: push_subscription, **)
    end
  end
end
