# == Schema Information
#
# Table name: follows
#
#  id              :bigint           not null, primary key
#  followable_type :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  followable_id   :bigint           not null
#  member_id       :bigint           not null
#
# Indexes
#
#  index_follows_on_followable             (followable_type,followable_id)
#  index_follows_on_member_and_followable  (member_id,followable_type,followable_id) UNIQUE
#  index_follows_on_member_id              (member_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#
require "test_helper"

class FollowTest < ActiveSupport::TestCase
  setup do
    @follow = follows(:one)
  end

  test "should generate an unsubscribe signed id" do
    signed_id = @follow.generate_unsubscribe_signed_id
    assert_not_nil signed_id

    found_follow = Follow.find_by_unsubscribe_signed_id!(signed_id)
    assert_equal @follow, found_follow
  end

  test "should raise error for invalid signed id" do
    invalid_signed_id = "invalid"
    assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
      Follow.find_by_unsubscribe_signed_id!(invalid_signed_id)
    end
  end

  # Additional tests can be added if there are more methods or functionalities in the Unsubscribeable concern
end
