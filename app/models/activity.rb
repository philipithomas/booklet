# == Schema Information
#
# Table name: activities
#
#  id           :bigint           not null, primary key
#  target_type  :string           not null
#  community_id :bigint           not null
#  member_id    :bigint           not null
#  target_id    :bigint           not null
#
# Indexes
#
#  index_activities_on_community_id  (community_id)
#  index_activities_on_member_id     (member_id)
#  index_activities_on_target        (target_type,target_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (member_id => members.id)
#
class Activity < ApplicationRecord
  belongs_to :member
  belongs_to :target, polymorphic: true
  belongs_to :community

  default_scope -> { includes(:target).order(id: :desc) }
  scope :visible_to, ->(current_member) {
    if current_member
      # Include all posts and replies where quarantined_at is nil
      # OR posts and replies that are quarantined but belong to the current_member
      where(target_type: "Post", target_id: Post.where("quarantined_at IS NULL OR member_id = ?", current_member.id).select(:id))
        .or(where(target_type: "Reply", target_id: Reply.where("quarantined_at IS NULL OR member_id = ?", current_member.id).select(:id)))
    else
      # Include only posts and replies where quarantined_at is nil for logged-out users
      where(target_type: "Post", target_id: Post.where(quarantined_at: nil).select(:id))
        .or(where(target_type: "Reply", target_id: Reply.where(quarantined_at: nil).select(:id)))
    end.order(id: :desc)
  }
  def created_at
    target.respond_to?(:published_at) ? target.published_at : target.created_at
  end
end
