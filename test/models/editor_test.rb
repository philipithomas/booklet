# == Schema Information
#
# Table name: editors
#
#  id                 :bigint           not null, primary key
#  email              :string
#  encrypted_password :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require "test_helper"

class EditorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
