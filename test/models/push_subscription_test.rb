# == Schema Information
#
# Table name: push_subscriptions
#
#  id            :bigint           not null, primary key
#  auth          :string
#  endpoint      :string
#  p256dh        :string
#  subscribed    :boolean          default(TRUE), not null
#  user_agent    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ahoy_visit_id :bigint
#  member_id     :bigint           not null
#
# Indexes
#
#  index_push_subscriptions_on_ahoy_visit_id           (ahoy_visit_id)
#  index_push_subscriptions_on_member_id               (member_id)
#  index_push_subscriptions_on_member_id_and_endpoint  (member_id,endpoint) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (ahoy_visit_id => ahoy_visits.id)
#  fk_rails_...  (member_id => members.id)
#
require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
