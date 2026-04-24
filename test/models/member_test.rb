# == Schema Information
#
# Table name: members
#
#  id                      :bigint           not null, primary key
#  confirmation_sent_at    :datetime
#  confirmation_token      :string
#  confirmed_at            :datetime
#  email                   :string
#  encrypted_password      :string           default(""), not null
#  invitation_accepted_at  :datetime
#  invitation_created_at   :datetime
#  invitation_limit        :integer
#  invitation_sent_at      :datetime
#  invitation_token        :string
#  invitations_count       :integer          default(0)
#  invited_by_type         :string
#  locked_at               :datetime
#  name                    :string           default(""), not null
#  newsletter_days_bitmask :integer
#  notify_mentions_email   :boolean          default(TRUE), not null
#  notify_mentions_push    :boolean          default(TRUE), not null
#  notify_new_posts_email  :boolean          default(FALSE), not null
#  notify_new_posts_push   :boolean          default(FALSE), not null
#  notify_newsletter_email :boolean          default(TRUE), not null
#  notify_newsletter_push  :boolean          default(TRUE), not null
#  permission              :integer          default("member"), not null
#  quarantined_at          :datetime
#  remember_created_at     :datetime
#  reset_password_sent_at  :datetime
#  reset_password_token    :string
#  slug                    :string           default(""), not null
#  source                  :string
#  subscribed_at           :datetime
#  unconfirmed_email       :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  ahoy_join_visit_id      :bigint
#  community_id            :bigint           not null
#  invited_by_id           :bigint
#  person_id               :integer
#
# Indexes
#
#  email_unique_per_community                  (email,community_id) UNIQUE
#  index_members_on_community_id               (community_id)
#  index_members_on_confirmation_token         (confirmation_token) UNIQUE
#  index_members_on_invitation_token           (invitation_token) UNIQUE
#  index_members_on_invited_by                 (invited_by_type,invited_by_id)
#  index_members_on_invited_by_id              (invited_by_id)
#  index_members_on_locked_at                  (locked_at)
#  index_members_on_lowercase_name             (lower((name)::text))
#  index_members_on_permission                 (permission)
#  index_members_on_quarantined_at             (quarantined_at)
#  index_members_on_reset_password_token       (reset_password_token) UNIQUE
#  index_members_on_source                     (source)
#  index_members_on_subscribed_at              (subscribed_at)
#  index_memberships_on_community_id_and_slug  (community_id,slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id) ON DELETE => nullify
#
require "test_helper"

class MemberTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @member = members(:member)

    @active_admin = members(:admin)
    @active_manager = members(:manager)
    @locked_member = members(:locked_member)
    @unconfirmed_member = members(:unactivated_member)
    @invited_member = members(:invited_member)
    @subscribed_member = members(:subscribed_member)
  end

  test "should be valid" do
    assert @member.valid?
  end

  test "email should not be disposable" do
    @member.email = "info@zzz-xxx.com"
    assert_not @member.valid?
  end

  test "name should be present" do
    @member.name = "   "
    assert_not @member.valid?
  end

  test "email should be present" do
    @member.email = "   "
    assert_not @member.valid?
  end

  test "email should be saved as lowercase" do
    @member.email = "BkLt@exAmple.coM"
    @member.skip_reconfirmation!
    @member.save
    assert_equal "bklt@example.com", @member.email
  end

  test "email should be stripped of whitespace before saving" do
    @member.email = "  bklt@example.com  "
    @member.skip_reconfirmation!
    @member.save
    assert_equal "bklt@example.com", @member.email
  end

  test "name should be stripped of whitespace before saving" do
    @member.name = "  Example Member  "
    @member.skip_reconfirmation!
    @member.save
    assert_equal "Example Member", @member.name
  end

  test "name should not be too long" do
    @member.name = "a" * 256
    assert_not @member.valid?
  end

  test "slug should be automatically created" do
    @member.save
    assert_not @member.slug.empty?
  end

  test "slug should be unique" do
    @member.save
    @member2 = Member.new(name: @member.name, email: "example2@example.com", community: @member.community)
    @member2.save
    assert_not_equal @member.slug, @member2.slug
  end

  test "email should be unique within the community" do
    @member.save
    @member2 = Member.new(name: "Example Member", email: @member.email, community: @member.community)
    assert_not @member2.valid?
  end

  test "email uniqueness should be case-insensitive" do
    @member.save
    @member2 = Member.new(name: "Example Member", email: @member.email.upcase, community: @member.community, password: "apassword")
    assert_not @member2.valid?

    @member2.email = @member.email.downcase
    assert_not @member2.valid?
  end

  test "email should not be unique across communities" do
    @member.save
    @member2 = Member.new(name: "Example Member", email: @member.email, community: communities(:other), password: "password", source: "public_join")
    assert @member2.valid?
  end

  test "locking an admin should remove admin permission" do
    assert @active_admin.admin?
    @active_admin.lock_access!
    assert_not @active_admin.admin?
  end

  test "invited member should be invited to sign up" do
    assert @invited_member.invited_to_sign_up?
  end

  test "active scope should return only confirmed and not locked members" do
    assert @member.confirmed_at.present?, "Setup member is not confirmed"
    assert @member.locked_at.nil?, "Setup member is locked"

    active_members = Member.active

    assert_includes active_members, @member, "Setup member is not included in active scope"

    active_members.each do |member|
      assert_not_nil member.confirmed_at, "Member #{member.id} is not confirmed but was included in active scope"
      assert_nil member.locked_at, "Member #{member.id} is locked but was included in active scope"
    end
  end

  test "active scope" do
    active_members = Member.active
    assert_includes active_members, @active_admin
    assert_includes active_members, @active_manager
    assert_includes active_members, @member
    assert_not_includes active_members, @locked_member
    assert_not_includes active_members, @unconfirmed_member
    assert_not_includes active_members, @subscribed_member
  end

  test "active_admins scope" do
    active_admins = Member.active_admins
    assert_includes active_admins, @active_admin
    assert_not_includes active_admins, @active_manager
    assert_not_includes active_admins, @member
    assert_not_includes active_admins, @locked_member
    assert_not_includes active_admins, @unconfirmed_member
    assert_not_includes active_admins, @subscribed_member
  end

  test "active_admins_or_managers scope" do
    active_admins_or_managers = Member.active_admins_or_managers
    assert_includes active_admins_or_managers, @active_admin
    assert_includes active_admins_or_managers, @active_manager
    assert_not_includes active_admins_or_managers, @member
    assert_not_includes active_admins_or_managers, @locked_member
    assert_not_includes active_admins_or_managers, @unconfirmed_member
    assert_not_includes active_admins_or_managers, @subscribed_member
  end

  test "active_members scope" do
    active_members = Member.active_members
    assert_includes active_members, @active_admin
    assert_includes active_members, @active_manager
    assert_includes active_members, @member
    assert_not_includes active_members, @locked_member
    assert_not_includes active_members, @unconfirmed_member
    assert_not_includes active_members, @subscribed_member
  end

  test "locked_members scope" do
    locked_members = Member.locked_members
    assert_not_includes locked_members, @active_admin
    assert_not_includes locked_members, @active_manager
    assert_not_includes locked_members, @member
    assert_includes locked_members, @locked_member
    assert_not_includes locked_members, @unconfirmed_member
    assert_not_includes locked_members, @subscribed_member
  end

  test "unconfirmed_members scope" do
    unconfirmed_members = Member.unconfirmed_members
    assert_not_includes unconfirmed_members, @active_admin
    assert_not_includes unconfirmed_members, @active_manager
    assert_not_includes unconfirmed_members, @member
    assert_not_includes unconfirmed_members, @locked_member

    assert_includes unconfirmed_members, @unconfirmed_member
    assert_includes unconfirmed_members, @subscribed_member
  end

  test "active_and_subscribed members scope" do
    active_and_subscribed_members = Member.active_and_subscribed
    assert_includes active_and_subscribed_members, @active_admin
    assert_includes active_and_subscribed_members, @active_manager
    assert_includes active_and_subscribed_members, @member
    assert_not_includes active_and_subscribed_members, @locked_member
    assert_not_includes active_and_subscribed_members, @unconfirmed_member
    assert_includes active_and_subscribed_members, @subscribed_member
  end

  # Test for Passwordlessable concern
  test "should find member by passwordless signed id" do
    signed_id = @member.generate_passwordless_signed_id
    found_member = Member.find_by_passwordless_signed_id!(signed_id)
    assert_equal @member, found_member
  end

  test "should not find member with invalid purpose" do
    signed_id = @member.generate_passwordless_signed_id

    assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
      # Tamper with the purpose to ensure it's being checked
      Member.find_signed!(signed_id, purpose: "wrong-purpose")
    end
  end

  test "should find member by email tokenizeable signed id" do
    signed_id = @member.generate_email_signed_token
    found_member = Member.find_by_email_signed_token(signed_id)
    assert_equal @member, found_member
  end

  test "should return nil with invalid email tokenizeable signed id" do
    signed_ids = [ "foo", nil, "" ]
    signed_ids.each do |signed_id|
      assert_nil Member.find_by_email_signed_token(signed_id)
    end
  end

  test "should return nil with nil tokenizeable signed id" do
    found_member = Member.find_by_email_signed_token(nil)
    assert_nil found_member
  end

  test "should follow community on create" do
    # fixtures don't trigger callbacks . . . .
    new_member = Member.create(name: "Example Member", email: "follower@example.com", password: "password", community: @member.community, source: "public_join")
    assert new_member.persisted?
    assert new_member.errors.empty?
    assert new_member.follows.find_by(followable: @member.community).present?
  end

  test "new member should be subscribed to the newsletter" do
    new_member = Member.create!(name: "Subscribed Member", email: "subscribed@example.com", password: "password", community: @member.community, source: "public_join")
    assert new_member.notify_newsletter_email?
    assert new_member.notify_newsletter_push?
  end

  test "status should return the correct status symbol" do
    assert_equal :active, members(:before_member).status

    assert_equal :unconfirmed, members(:unactivated_member).status

    assert_equal :locked, members(:locked_member).status

    assert_equal :admin, members(:admin).status

    assert_equal :invited, members(:invited_member).status

    assert_equal :subscribed, members(:subscribed_member).status

    assert_equal :quarantined, members(:quarantined_member).status

    assert_equal :unconfirmed, Member.new.status
  end

  test "initials does not break with various names" do
    [ "-", '..\"', "../" ].each do |name|
      @member.update(name: name)
      assert_nothing_raised do
        @member.initials
      end
    end
  end

  test "cannot revoke admin permission if it is the last admin" do
    assert_raises(ActiveRecord::RecordInvalid) do
      @active_admin.update!(permission: :member)
    end

    assert_equal "admin", @active_admin.reload.permission

    @member.update!(permission: :admin)

    assert_nothing_raised do
      @active_admin.update!(permission: :member)
    end
  end

  test "as_json should include about field when present" do
    json = @active_admin.as_json
    assert_equal @active_admin.name, json["name"]
    assert_nil json[:about]

    @active_admin.update(about: "This is a test about field")
    json = @active_admin.as_json
    assert_includes json["about"], "This is a test about field"
  end
end
