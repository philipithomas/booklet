class DeliverPushNotificationJob < ApplicationJob
  queue_as :high

  def perform(**)
    PushNotification.create!(**)
  end
end
