# == Schema Information
#
# Table name: views
#
#  id            :bigint           not null, primary key
#  viewable_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ahoy_visit_id :bigint
#  member_id     :bigint           not null
#  viewable_id   :bigint           not null
#
# Indexes
#
#  index_views_on_ahoy_visit_id                  (ahoy_visit_id)
#  index_views_on_member_id                      (member_id)
#  index_views_on_viewable_type_and_viewable_id  (viewable_type,viewable_id)
#
# Foreign Keys
#
#  fk_rails_...  (ahoy_visit_id => ahoy_visits.id)
#  fk_rails_...  (member_id => members.id)
#
require "test_helper"

class ViewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
