# == Schema Information
#
# Table name: people
#
#  id                     :bigint           not null, primary key
#  max_member_direct_adds :integer          default(10000)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Person < ApplicationRecord
  has_many :verifications, dependent: :destroy
  has_many :members, dependent: :nullify
end
