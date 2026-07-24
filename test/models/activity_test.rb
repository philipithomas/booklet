# == Schema Information
#
# Table name: activities
#
#  id           :bigint           not null, primary key
#  target_type  :string           not null
#  community_id :bigint           not null
#  member_id    :bigint           not null
#  target_id    :bigint           not null
#
# Indexes
#
#  index_activities_on_community_id  (community_id)
#  index_activities_on_member_id     (member_id)
#  index_activities_on_target        (target_type,target_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (member_id => members.id)
#
require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
