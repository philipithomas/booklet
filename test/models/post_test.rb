# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  prompt         :string
#  published_at   :datetime
#  quarantined_at :datetime
#  replies_count  :integer          default(0), not null
#  slug           :string           not null
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :bigint           not null
#  member_id      :bigint           not null
#
# Indexes
#
#  index_posts_on_community_id           (community_id)
#  index_posts_on_community_id_and_slug  (community_id,slug) UNIQUE
#  index_posts_on_member_id              (member_id)
#  index_posts_on_quarantined_at         (quarantined_at)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (member_id => members.id)
#
require "test_helper"

class PostTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @community = communities(:lab)
    @member = members(:member)
    @post = Post.new(title: "Post Title", body: "Post body", member: @member, community: @community)
  end

  test "should be valid" do
    assert @post.valid?
  end

  test "title should be present" do
    @post.title = "     "
    assert_not @post.valid?
  end

  test "body should be present" do
    @post.body = "     "
    assert_not @post.valid?
  end

  test "title should not be too long" do
    @post.title = "a" * 256
    assert_not @post.valid?
  end

  test "slug should be unique per community" do
    duplicate_post = @post.dup
    @post.save
    assert_not duplicate_post.valid?
  end

  test "should set published_at if published" do
    @post.save
    assert_nil @post.published_at
    @post.publish!
    assert_not_nil @post.published_at
  end

  test "feed should return posts in descending order of published_at" do
    posts = Post.feed_for(nil)
    assert_equal posts.first, posts.max_by(&:published_at)
  end

  test "should create an activity on publish" do
    @post.save
    @post.publish!
    assert @post.activities.exists?, "No activity created on publish"
    assert @post.activities.count == 1, "More than one activity created on publish"
  end

  test "should have activity if directly published" do
    @post.published_at = Time.zone.now
    @post.save
    assert @post.activities.exists?, "No activity created on publish"
    assert @post.activities.count == 1, "More than one activity created on publish"
  end

  test "should enqueue moderation and search job on create" do
    assert_enqueued_jobs 2 do
      @post.save
    end
  end

  test "should enqueue moderation and search job on publish" do
    @post.save # first save the post
    clear_enqueued_jobs # clear any previously enqueued jobs

    assert_enqueued_jobs 0 do
      @post.update(title: "Updated Title")
    end

    @post.publish!

    assert_enqueued_jobs 2 do
      @post.update(title: "Updated Title 2")
    end
  end

  test "quarantined post should not appear in feed" do
    @post.published_at = Time.zone.now
    @post.save
    assert_includes Post.feed_for(nil), @post
    @post.update(quarantined_at: Time.zone.now)
    assert_not_includes Post.feed_for(nil), @post
    assert_includes Post.feed_for(@post.member), @post
  end

  test "qurantined member should not have post in feed" do
    @post.published_at = Time.zone.now
    @post.save
    assert_includes Post.feed_for(nil), @post

    @post.member.quarantine!

    assert_not_includes Post.feed_for(nil), @post
    assert_includes Post.feed_for(@post.member), @post
  end

  test "quarantined post should not be visible to non-author and non-admins" do
    other_member = members(:other_member)
    @post.update(quarantined_at: Time.zone.now)
    assert_not PostPolicy.new(other_member, @post).show?
  end

  test "quarantined post should be visible to author" do
    @post.update(quarantined_at: Time.zone.now)
    assert PostPolicy.new(@member, @post).show?
  end

  test "quarantined post should be visible to admins" do
    admin_member = members(:admin)
    @post.update(quarantined_at: Time.zone.now)
    assert PostPolicy.new(admin_member, @post).show?
  end
end
