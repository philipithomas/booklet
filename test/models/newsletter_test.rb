# == Schema Information
#
# Table name: newsletters
#
#  id                     :bigint           not null, primary key
#  state                  :integer          default("pending"), not null
#  subject                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  community_id           :bigint
#  member_id              :bigint
#  previous_newsletter_id :bigint
#
# Indexes
#
#  index_newsletters_on_community_id            (community_id)
#  index_newsletters_on_member_id               (member_id)
#  index_newsletters_on_previous_newsletter_id  (previous_newsletter_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (previous_newsletter_id => newsletters.id)
#
require "test_helper"

class NewsletterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @community = communities(:lab)
    @member = members(:member)

    @newsletter = Newsletter.new(community: @community)
  end

  test "should be valid" do
    assert @newsletter.valid?
  end

  test "should set content and state on create" do
    @newsletter.save

    assert_nil @newsletter.previous_newsletter

    assert_not_nil @newsletter.new_posts
    assert_not_nil @newsletter.new_members
    assert_not_nil @newsletter.existing_post_with_new_replies

    assert @newsletter.new_posts.count > 0
    assert @newsletter.new_members.count > 0
    assert @newsletter.existing_post_with_new_replies.count > 0

    assert @newsletter.success?
  end

  test "should have previous newsletter attribute set if not the first one" do
    @first_newsletter = Newsletter.create(community: @community)
    @second_newsletter = Newsletter.create(community: @community)
    assert_nil @first_newsletter.previous_newsletter
    assert_equal @second_newsletter.previous_newsletter, @first_newsletter
  end

  test "should enqueue NewsletterMailer.new_newsletter job when state is success" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      @newsletter.save!
    end
  end

  test "should not enqueue NewsletterMailer.new_newsletter job when state is not success" do
    @newsletter.save!

    assert_no_enqueued_jobs do
      @newsletter.skip_no_content!
    end
  end

  test "should skip if only new_members are present, and include new members in subsequent newsletter" do
    @newsletter.save!

    # New member should skip newsletter
    new_member = Member.create!(community: @community, confirmed_at: Time.now, name: "New Member", email: "foo@example.com", password: "p@ssw0rd!!", source: "public_join")
    @second_newsletter = Newsletter.create(community: @community)

    assert_equal @second_newsletter.new_posts, []
    assert @second_newsletter.new_members.count > 0
    assert_equal @second_newsletter.existing_post_with_new_replies, []

    assert @second_newsletter.skip_no_content?

    # Subsequent newsletter includes new member
    Post.create!(community: @community, member: new_member, title: "New Post", body: "New Post Body", published_at: Time.now)
    @third_newsletter = Newsletter.create(community: @community)
    assert @third_newsletter.new_posts.count > 0
    assert_equal @third_newsletter.new_members, [ new_member ]
    assert @third_newsletter.success?
  end

  test "generated newsletter should have a subject" do
    @newsletter.save!
    assert_not_nil @newsletter.subject
    assert @newsletter.subject.length > 0
  end
end
