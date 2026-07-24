# == Schema Information
#
# Table name: ahoy_messages
#
#  id            :bigint           not null, primary key
#  campaign      :string
#  content       :text
#  mailer        :string
#  sent_at       :datetime
#  subject       :text
#  to            :string
#  token         :string
#  user_type     :string
#  community_id  :bigint
#  newsletter_id :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_ahoy_messages_on_campaign       (campaign)
#  index_ahoy_messages_on_community_id   (community_id)
#  index_ahoy_messages_on_newsletter_id  (newsletter_id)
#  index_ahoy_messages_on_to             (to)
#  index_ahoy_messages_on_token          (token) UNIQUE
#  index_ahoy_messages_on_user           (user_type,user_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (newsletter_id => newsletters.id)
#
class Ahoy::Message < ApplicationRecord
  self.table_name = "ahoy_messages"

  belongs_to :user, polymorphic: true, optional: true
  belongs_to :community, optional: true

  encrypts :to, deterministic: true
  encrypts :content
end
