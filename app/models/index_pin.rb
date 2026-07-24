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
class IndexPin < ApplicationRecord
  validates :code, presence: true
  validates :email, presence: true
  validates :expires_at, presence: true
  validates :code, uniqueness: true
  encrypts :code, deterministic: true

  def self.create_pin(email)
    email = email.to_s.strip.downcase
    pin = IndexPin.create(code: SecureRandom.random_number(100000..999999).to_s, email: email, expires_at: 10.minutes.from_now)
    IndexMailer.login_pin(pin).deliver_now

    # recycle old pins
    pins = IndexPin.where(email: email)
    pins.excluding(pins.order(created_at: :desc).limit(10)).destroy_all

    pin
  end
end
