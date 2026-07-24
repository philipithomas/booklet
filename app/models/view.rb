# == Schema Information
#
# Table name: views
#
#  id            :bigint           not null, primary key
#  viewable_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ahoy_visit_id :bigint
#  member_id     :bigint           not null
#  viewable_id   :bigint           not null
#
# Indexes
#
#  index_views_on_ahoy_visit_id                  (ahoy_visit_id)
#  index_views_on_member_id                      (member_id)
#  index_views_on_viewable_type_and_viewable_id  (viewable_type,viewable_id)
#
# Foreign Keys
#
#  fk_rails_...  (ahoy_visit_id => ahoy_visits.id)
#  fk_rails_...  (member_id => members.id)
#
class View < ApplicationRecord
  belongs_to :viewable, polymorphic: true
  belongs_to :member

  POST_PREVIEW_LIMIT = 6

  after_create_commit :broadcast_post_view, if: -> { viewable_type == "Post" }

  def self.preview_for_post(post)
    Member.joins(:views)
      .where(views: { viewable: post })
      .select("members.*, MAX(views.created_at) as view_created_at")
      .includes(photo_attachment: :blob)
      .group("members.id")
      .order("view_created_at DESC")
      .limit(POST_PREVIEW_LIMIT)
  end

  def self.count_for_post(post)
    select("DISTINCT views.member_id")
      .where(viewable: post)
      .count
  end

  private

  def broadcast_post_view
    broadcast_update_to(
      viewable,
      partial: "communities/post_views/views",
      locals: {
        view_count: View.count_for_post(viewable),
        members: View.preview_for_post(viewable),
        post: viewable
      },
      target: "post_views"
    )
  end
end
