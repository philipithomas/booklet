require "test_helper"

class DeliverPushNotificationJobTest < ActiveJob::TestCase
  test "DeliverPushNotificationJob is performed with correct arguments" do
    push_notification_params = {
      title: "Test Notification",
      body: "This is a test notification body",
      source_type: "Post",
      source_id: posts(:post).id,
      push_subscription_id: push_subscriptions(:mmember_push_subscription).id
    }

    assert_difference "PushNotification.count", 1 do
      DeliverPushNotificationJob.perform_now(**push_notification_params)
    end

    push_notification = PushNotification.last

    assert_equal "Test Notification", push_notification.title
    assert_equal "This is a test notification body", push_notification.body
    assert_equal "Post", push_notification.source_type
    assert_equal posts(:post).id, push_notification.source_id
    assert_equal push_subscriptions(:mmember_push_subscription).id, push_notification.push_subscription_id
  end
end
