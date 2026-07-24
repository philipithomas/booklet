# == Schema Information
#
# Table name: mentions
#
#  id          :bigint           not null, primary key
#  source_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  member_id   :bigint           not null
#  source_id   :bigint           not null
#
# Indexes
#
#  index_mentions_on_member_id                                (member_id)
#  index_mentions_on_source                                   (source_type,source_id)
#  index_mentions_on_source_type_and_source_id_and_member_id  (source_type,source_id,member_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#
class Mention < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :member

  validates :member_id, uniqueness: { scope: %i[source_type source_id] }

  after_create_commit :send_mention_notification, :create_follow

  private

  def send_mention_notification
    return if member == source.member

    if source.is_a?(Post)
      PostMentionNotificationJob.set(wait: 1.minute).perform_later(member, source)
    elsif source.is_a?(Reply)
      ReplyMentionNotificationJob.set(wait: 1.minute).perform_later(member, source)
    else
      raise "Unknown source type for mention notification"
    end
  end

  def create_follow
    followable = source.is_a?(Reply) ? source.post : source
    Follow.find_or_create_by!(member: member, followable: followable)
  end
end
