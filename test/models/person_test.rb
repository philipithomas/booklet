# == Schema Information
#
# Table name: people
#
#  id                     :bigint           not null, primary key
#  max_member_direct_adds :integer          default(10000)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
require "test_helper"

class PersonTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
