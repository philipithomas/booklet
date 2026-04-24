# == Schema Information
#
# Table name: index_pins
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  email      :string           not null
#  expires_at :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_index_pins_on_email  (email)
#
require "test_helper"

class IndexPinTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
