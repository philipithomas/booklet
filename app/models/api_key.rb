# == Schema Information
#
# Table name: api_keys
#
#  id           :bigint           not null, primary key
#  deleted_at   :datetime
#  key_hash     :string           not null
#  last_used_at :datetime
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#
# Indexes
#
#  index_api_keys_on_community_id  (community_id)
#  index_api_keys_on_deleted_at    (deleted_at)
#  index_api_keys_on_key_hash      (key_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
class APIKey < ApplicationRecord
  belongs_to :community
  audited associated_with: :community, only: [ :name ], on: [ :create, :destroy ]

  before_create :generate_and_store_hash

  attr_accessor :plaintext_key

  validates :name, presence: true

  default_scope { where(deleted_at: nil) }

  audited associated_with: :community

  def external_key
    raise "No plaintext key" unless plaintext_key
    "bklt_#{id}_#{plaintext_key}"
  end

  def self.find_by_external_key(external_key)
    id, plaintext_key = external_key.split("_")[1..2]
    key = find_by(id: id)
    return nil unless key
    if BCrypt::Password.new(key.key_hash) == plaintext_key
      key.update(last_used_at: Time.now)
      return key
    end
    nil
  end

  def soft_destroy
    update!(deleted_at: Time.now)
  end

  private

  def generate_and_store_hash
    self.plaintext_key = SecureRandom.hex(16)
    self.key_hash = BCrypt::Password.create(plaintext_key)
  end
end
