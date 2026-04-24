require "test_helper"

class EnqueueMemberPushNotificationsJobTest < ActiveJob::TestCase
  test "EnqueueMemberPushNotificationsJob is enqueued" do
    assert_enqueued_with(job: EnqueueMemberPushNotificationsJob) do
      EnqueueMemberPushNotificationsJob.perform_later(members(:member), title: "hello", body: "world", source: posts(:post))
    end
  end

  test "EnqueueMemberPushNotificationsJob is performed with correct arguments" do
    member = members(:member)
    notification_params = { title: "hello", body: "world", source: posts(:post) }

    assert_enqueued_with(job: DeliverPushNotificationJob) do
      EnqueueMemberPushNotificationsJob.perform_now(member, **notification_params)
    end

    perform_enqueued_jobs

    push_notification = PushNotification.last
    assert_equal push_subscriptions(:mmember_push_subscription).id, push_notification.push_subscription_id
    assert_equal "hello", push_notification.title
    assert_equal "world", push_notification.body
    assert_equal posts(:post), push_notification.source
  end
end
