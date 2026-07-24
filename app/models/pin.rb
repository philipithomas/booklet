# == Schema Information
#
# Table name: pins
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  expires_at :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint           not null
#
# Indexes
#
#  index_pins_on_member_id  (member_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#
class Pin < ApplicationRecord
  belongs_to :member
  validates :code, presence: true
  validates :expires_at, presence: true
  validates :code, uniqueness: true
  encrypts :code, deterministic: true

  def self.create_with_email(email)
    email.downcase!.strip!
    pin = create(code: SecureRandom.random_number(100000..999999), expires_at: 10.minutes.from_now, email: email)
    IndexMailer.login_pin(self).deliver_now

    # recycle old pins
    where(email: email).excluding(order(created_at: :desc).limit(10)).destroy_all

    pin
  end
end
