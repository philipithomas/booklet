# == Schema Information
#
# Table name: push_notifications
#
#  id                   :bigint           not null, primary key
#  body                 :text             not null
#  source_type          :string           not null
#  title                :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  push_subscription_id :bigint           not null
#  source_id            :bigint           not null
#
# Indexes
#
#  index_push_notifications_on_push_subscription_id  (push_subscription_id)
#  index_push_notifications_on_source                (source_type,source_id)
#
# Foreign Keys
#
#  fk_rails_...  (push_subscription_id => push_subscriptions.id)
#
require "test_helper"

class PushNotificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
