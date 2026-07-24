# == Schema Information
#
# Table name: searchable_contents
#
#  id           :bigint           not null, primary key
#  content_type :string           not null
#  document     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  content_id   :bigint           not null
#
# Indexes
#
#  index_searchable_contents_on_community_id  (community_id)
#  index_searchable_contents_on_content       (content_type,content_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
require "test_helper"

class SearchableContentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
