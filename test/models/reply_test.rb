# == Schema Information
#
# Table name: replies
#
#  id             :bigint           not null, primary key
#  quarantined_at :datetime
#  slug           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  member_id      :bigint           not null
#  post_id        :bigint           not null
#
# Indexes
#
#  index_replies_on_member_id         (member_id)
#  index_replies_on_post_id           (post_id)
#  index_replies_on_post_id_and_slug  (post_id,slug) UNIQUE
#  index_replies_on_quarantined_at    (quarantined_at)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (post_id => posts.id)
#
require "test_helper"

class ReplyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @community = communities(:lab)
    @member = members(:member)
    @post = posts(:post)
    @reply = Reply.new(body: "Reply body", member: @member, post: @post)
  end

  test "should be valid" do
    assert @reply.valid?
  end

  test "body should be present" do
    @reply.body = "     "
    assert_not @reply.valid?
  end

  test "slug should be unique per reply" do
    duplicate_reply = @reply.dup
    @reply.save
    assert_not duplicate_reply.valid?
  end

  test "should create an activity on publish" do
    @reply.save
    assert @reply.activities.exists?, "No activity created on publish"
    assert @reply.activities.count == 1, "More than one activity created on publish"
  end

  test "should enqueue moderation and search job on create" do
    assert_enqueued_jobs 7 do
      @reply.save
    end
  end

  test "should enqueue moderation job and search job on update" do
    @reply.save # first save the post
    clear_enqueued_jobs # clear any previously enqueued jobs

    assert_enqueued_jobs 2 do
      @reply.update!(body: "This is new")
    end
  end

  test "quarantined reply should not appear in feed" do
    @reply.save
    assert_includes @post.replies.feed_for(nil), @reply
    @reply.update(quarantined_at: Time.zone.now)
    assert_not_includes @post.replies.feed_for(nil), @reply
    assert_includes @post.replies.feed_for(@reply.member), @reply
  end

  test "quarantined member should not have replies appear in feed" do
    @reply.save
    assert_includes @post.replies.feed_for(nil), @reply
    @reply.member.quarantine!
    assert_not_includes @post.replies.feed_for(nil), @reply
    assert_includes @post.replies.feed_for(@reply.member), @reply
  end

  test "quarantined reply should not be visible to non-author and non-admins" do
    other_member = members(:other_member)
    @reply.update(quarantined_at: Time.zone.now)
    assert_not ReplyPolicy.new(other_member, @reply).show?
  end

  test "quarantined reply should be visible to author" do
    @reply.update(quarantined_at: Time.zone.now)
    assert ReplyPolicy.new(@member, @reply).show?
  end

  test "quarantined post should be visible to admins" do
    admin_member = members(:admin)
    @reply.update(quarantined_at: Time.zone.now)
    assert ReplyPolicy.new(admin_member, @reply).show?
  end
end
