# == Schema Information
#
# Table name: communities
#
#  id                                 :bigint           not null, primary key
#  brand_color                        :string           default("#4D3DF7"), not null
#  default_newsletter_days_bitmask    :integer          default(127), not null
#  directory_enabled                  :boolean          default(TRUE), not null
#  email                              :string           default(""), not null
#  email_visibility                   :string           default("open"), not null
#  name                               :string           not null
#  newsletter_days_bitmask            :integer          default(127), not null
#  open_ai_content_moderation_enabled :boolean          default(TRUE), not null
#  open_ai_member_moderation_enabled  :boolean          default(FALSE), not null
#  signups                            :integer          default("invite_only"), not null
#  slug                               :string           not null
#  vapid_private_key                  :string
#  vapid_public_key                   :string
#  visibility                         :integer          default("private"), not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  ahoy_create_visit_id               :bigint
#  pinned_post_id                     :bigint
#
# Indexes
#
#  index_communities_on_pinned_post_id  (pinned_post_id)
#  index_communities_on_slug            (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (pinned_post_id => posts.id) ON DELETE => nullify
#
require "test_helper"

class CommunityTest < ActiveSupport::TestCase
  def setup
    @community = communities(:lab)
  end

  test "should be valid" do
    assert @community.valid?
  end

  test "public_invite_only should also be valid" do
    @community.visibility = :public
    assert @community.valid?
  end

  test "unlisted_invite_only should also be valid" do
    @community.visibility = :unlisted
    assert @community.valid?
  end

  test "name should be present" do
    @community.name = " "
    assert_not @community.valid?
  end

  test "name should not be too long" do
    @community.name = "a" * 256
    assert_not @community.valid?
  end

  test "name is stripped of whitespace before saving" do
    @community.name = "  My Community  "
    @community.save
    assert_equal "My Community", @community.name
  end

  test "slug should be present" do
    @community.slug = " "
    assert_not @community.valid?
  end

  test "slug should not be too long" do
    @community.slug = "a" * 256
    assert_not @community.valid?
  end

  test "slug should not be a restricted name" do
    @community.slug = "philipithomas"
    assert_not @community.valid?
  end

  test "invalid slugs are not allowed" do
    [ "Hello", "hello world", "helloworld!", "hello_world" ].each do |slug|
      @community.slug = slug
      assert_not @community.valid?
    end
  end

  test "slugs should be unique" do
    @community.save
    @community2 = @community.dup
    @community2.slug = @community.slug
    assert_not @community2.valid?
  end

  test "slugs should be case insensitive" do
    @community.save
    @community2 = @community.dup
    @community2.slug = @community.slug.upcase

    assert_not @community2.valid?

    @community2.slug = @community.slug.downcase
    assert_not @community2.valid?
  end

  test "white has sufficient color contrast to dark" do
    @community.brand_color = "#FFFFFF"
    assert @community.brand_color_has_sufficient_contrast_to_dark
  end

  test "white lacks sufficient color contrast to light" do
    @community.brand_color = "#FFFFFF"
    assert_not @community.brand_color_has_sufficient_contrast_to_light
  end

  test "black has sufficient color contrast to light" do
    @community.brand_color = "#000000"
    assert @community.brand_color_has_sufficient_contrast_to_light
  end

  test "black lacks sufficient color contrast to dark" do
    @community.brand_color = "#000000"
    assert_not @community.brand_color_has_sufficient_contrast_to_dark
  end

  test "label color for black brand color should be light" do
    @community.brand_color = "#000000"
    assert_equal "#FFFFFF", @community.light_mode_label_color
  end

  test "label color for white brand color should be dark" do
    @community.brand_color = "#FFFFFF"
    assert_equal "#111111", @community.dark_mode_label_color
  end

  test "initials for Laboratory should be 'L'" do
    assert_equal "L", @community.initials
  end

  test "initials for 'my laboratory' should be 'ML'" do
    @community.name = "my laboratory"
    assert_equal "ML", @community.initials
  end

  test "initials for 'game of thrones' should be 'GT'" do
    @community.name = "game of tHrones"
    assert_equal "GT", @community.initials
  end

  test "when no custom domain, then host should be app host subdomain" do
    requires_multiuser_mode!
    assert_equal "lab.localtest.me", @community.host
  end

  test "when custom domain but not verified, then host should be app host subdomain" do
    requires_multiuser_mode!
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: false)
    assert_equal "lab.localtest.me", @community.host
  end

  test "when custom domain and verified, then host should be custom domain" do
    requires_multiuser_mode!
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: true)
    assert_equal "lab.fbi.com", @community.host
  end

  test "when custom domain and verified but redirect_for_name, then host should be app host subdomain" do
    requires_multiuser_mode!
    Domain.create!(community: @community, domain: "www.lab.fbi.com", verified: true, redirect_for_name: "lab.fbi.com")
    assert_equal "lab.localtest.me", @community.host
  end

  test "when multiple custom domains and verified, then host should be first custom domain without redirect_for_name" do
    requires_multiuser_mode!
    Domain.create!(community: @community, domain: "www.lab.fbi.com", verified: true, redirect_for_name: "lab.fbi.com")
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: true)
    Domain.create!(community: @community, domain: "old.fbi.com", verified: true, redirect_for_name: "lab.fbi.com")
    assert_equal "lab.fbi.com", @community.host
  end

  test "when multiple custom domains but not all verified, then unverified_domain? should be true" do
    assert_not @community.unverified_domain?
    domain = Domain.create!(community: @community, domain: "lab.fbi.com", verified: false)
    assert @community.unverified_domain?
    Domain.create!(community: @community, domain: "www.lab.fbi.com", verified: true, redirect_for_name: "lab.fbi.com")
    assert @community.unverified_domain?
    domain.update!(verified: true)
    assert_not @community.unverified_domain?
  end

  test "new communities should default to newsletters every day of the week" do
    @community.save!
    assert_equal 127, @community.newsletter_days_bitmask
  end

  test "should set and unset a default newsletter day" do
    @community.set_newsletter_day("Monday", false)
    assert_not @community.newsletter_on?("Monday"), "Monday should have been removed from default newsletter days"

    @community.set_newsletter_day("Monday", true)
    assert @community.newsletter_on?("Monday"), "Monday should have been added back to default newsletter days"
  end

  test "should unset all default newsletter days" do
    NewsletterDaysBitmask::DAYS.each_key do |day|
      @community.set_newsletter_day(day, true)
    end
    @community.save!
    NewsletterDaysBitmask::DAYS.each_key do |day|
      assert @community.newsletter_on?(day), "All default newsletter days should be set"
    end

    NewsletterDaysBitmask::DAYS.each_key do |day|
      @community.set_newsletter_day(day, false)
    end
    @community.save!
    NewsletterDaysBitmask::DAYS.each_key do |day|
      assert_not @community.newsletter_on?(day), "#{day} should be unset, but bitmask is #{@community.newsletter_days_bitmask}"
    end
  end

  test "should identify if any default newsletter days are present" do
    assert @community.newsletter_days_present?, "Default newsletter days should be present by default"

    # Unset all days
    [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ].each do |day|
      @community.set_newsletter_day(day, false)
    end
    @community.save!

    assert @community.newsletter_days_bitmask.zero?, "Default newsletter days should be unset"
  end

  test "vapid keys are created after community creation" do
    community = Community.new(name: "Test Community", email: "test@example.com")
    assert_nil community.vapid_public_key
    assert_nil community.vapid_private_key

    community.save!
    community.reload
    assert_not_nil community.vapid_public_key
    assert_not_nil community.vapid_private_key
  end
end
