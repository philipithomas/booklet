# == Schema Information
#
# Table name: follows
#
#  id              :bigint           not null, primary key
#  followable_type :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  followable_id   :bigint           not null
#  member_id       :bigint           not null
#
# Indexes
#
#  index_follows_on_followable             (followable_type,followable_id)
#  index_follows_on_member_and_followable  (member_id,followable_type,followable_id) UNIQUE
#  index_follows_on_member_id              (member_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#
class Follow < ApplicationRecord
  include Unsubscribeable

  belongs_to :member
  belongs_to :followable, polymorphic: true

  audited associated_with: :community

  def community
    member.community
  end
end
