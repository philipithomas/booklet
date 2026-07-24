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
class Member < ApplicationRecord
  extend FriendlyId
  include Initializeable
  include Passwordlessable
  include EmailTokenizeable
  include Moderatable
  include NewsletterDaysBitmask
  include Searchable
  include Mentionable
  include Verifiable
  include Addable

  devise :invitable, :database_authenticatable, :registerable,
    :rememberable, :lockable, :confirmable

  has_rich_text :about

  has_one_attached :photo, strict_loading: true, dependent: :destroy do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 800, 800, { crop: "attention" } ]
  end

  visitable :ahoy_join_visit

  friendly_id :name, use: %i[slugged history scoped], scope: :community, slug_limit: 50

  attribute :source, :string # Bug in Rails - race condition in migrations
  enum source: %w[creator invited public_join direct_add imported].index_by(&:itself), _prefix: true
  enum :permission, { member: 0, manager: 1, admin: 2 }, default: :member

  audited associated_with: :community

  validates :name, presence: true, length: { maximum: 255 }
  validates :permission, presence: true
  validate :email_must_be_deliverable
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { scope: :community_id, case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, disposable_email: true
  validate :ensure_at_least_one_admin_remains, if: :admin_permission_changed?
  validates_length_of :password, within: Devise.password_length.min..Devise.password_length.max, allow_blank: true

  belongs_to :community, strict_loading: true
  belongs_to :person, optional: true, strict_loading: true

  has_many :activities, dependent: :destroy
  has_many :views, dependent: :destroy
  has_many :invitations, class_name: to_s, as: :invited_by
  has_many :posts, dependent: :destroy, strict_loading: true
  has_many :replies, dependent: :destroy, strict_loading: true
  has_many :follows, dependent: :destroy, strict_loading: true
  has_and_belongs_to_many :newsletters
  has_many :newsletter_new_members, dependent: :destroy
  has_many :login_activities, as: :user
  has_one :searchable_content, as: :content, dependent: :destroy
  has_many :newsletters
  has_many :searches, dependent: :destroy
  has_many :pins, dependent: :destroy
  has_many :visits, class_name: "Ahoy::Visit", dependent: :destroy, foreign_key: "user_id", inverse_of: :user, primary_key: "id"
  has_many :events, class_name: "Ahoy::Event", dependent: :destroy, foreign_key: "user_id", inverse_of: :user, primary_key: "id"
  has_many :messages, class_name: "Ahoy::Message", as: :user
  has_many :push_subscriptions, dependent: :destroy
  has_many :mentions, dependent: :destroy

  attr_accessor :send_welcome # used during new member creation

  after_validation :move_friendly_id_error_to_title

  before_save :downcase_email, :strip_whitespace, :prevent_admin_locking

  after_create_commit -> {
    follows.create!(followable: community)

    if (confirmed_at? || subscribed_at?) && send_welcome
      MemberMailer.welcome(self).deliver_later
    end

    FounderMailer.welcome(self).deliver_later(wait: 20.minutes) if admin? && Member.where(email: email, permission: :admin).count <= 1 && community.members.count <= 1
    InviteToHQJob.set(wait: 21.minutes).perform_later self if admin?
    PostInAdminChatJob.perform_later("➕ New member - #{community.slug} - #{status} #{email}")
    enqueue_search_embedding
  }

  scope :default, -> { with_attached_photo.order(created_at: :desc) }
  scope :active, -> { where.not(confirmed_at: nil).where(locked_at: nil).with_attached_photo }
  scope :listed, -> { active.where(quarantined_at: nil).order(updated_at: :desc) }
  scope :active_admins, -> { active.where(permission: :admin).where(locked_at: nil).where.not(confirmed_at: nil).with_attached_photo }
  scope :active_admins_or_managers, -> { active.where(permission: %i[admin manager]).where(locked_at: nil).where.not(confirmed_at: nil).with_attached_photo }
  scope :active_members, -> { active.where(locked_at: nil).where.not(confirmed_at: nil).with_attached_photo }
  scope :locked_members, -> { where.not(locked_at: nil).with_attached_photo }
  scope :unconfirmed_members, -> { where(confirmed_at: nil).with_attached_photo }
  scope :invited, -> { where(invitation_accepted_at: nil).where.not(invitation_token: nil).with_attached_photo }
  scope :active_and_subscribed, -> { where(locked_at: nil).where.not(confirmed_at: nil).or(where.not(subscribed_at: nil)) }

  has_rich_text :about

  has_many :activities, dependent: :destroy
  has_many :views, dependent: :destroy

  after_save_commit :find_and_set_person, if: -> { saved_change_to_email? }

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = conditions.delete(:email)
    community_id = conditions.delete(:community_id)
    where(conditions.to_hash).where([ "lower(email) = :email AND community_id = :community_id", { email: email.downcase, community_id: community_id } ]).first
  end

  def status
    return :locked if locked_at.present?
    return :quarantined if quarantined_at.present?
    return :admin if admin?
    return :active if confirmed_at.present?
    return :subscribed if subscribed_at.present?
    return :invited if invitation_token.present?
    :unconfirmed
  end

  def send_reset_password_instructions
    if !confirmed?
      return send_confirmation_instructions
    end

    super
  end

  def pending_invitation_acceptance?
    invitation_token.present? and invitation_accepted_at.nil?
  end

  def manager_or_admin?
    manager? || admin?
  end

  def first_name
    name.present? ? NameOfPerson::PersonName.full(name).first : nil
  end

  def last_name
    name.present? ? NameOfPerson::PersonName.full(name).last : nil
  end

  def self.safely_create_and_invite_member(community, inviting_member, sanitized_member_params)
    invitation_window = 8.hours
    invitation_window_limit = 1000
    invitation_window_count = Ahoy::Event.where_event(:member_invitation_created, community_id: community.id).where("time > ?", invitation_window.ago).count
    skip_invitation = invitation_window_count >= invitation_window_limit

    existing_member = community.members.find_by(email: sanitized_member_params[:email].strip.downcase)
    if existing_member
      return existing_member
    end

    sanitized_member_params[:source] = "invited"

    invited_member = community.members.invite!(sanitized_member_params, inviting_member) do |m|
      m.skip_invitation = skip_invitation
      Rails.logger.info "Invitation limit reached for community #{community.id} by member #{inviting_member.id} - #{invitation_count} invitations in the past 24 hours" if skip_invitation
    end

    Ahoy::Event.create(name: "member_invitation_created", properties: { community_id: community.id, inviter_id: inviting_member.id, invited_member_id: invited_member.id })
    invited_member
  end

  def send_invitation_email
    MemberMailer.invitation(self).deliver_later
  end

  def self.invitation(s_in_past_24_hours)
    Ahoy::Event.where(name: "member_invitation_created", properties: { community_id: id }).where("time > ?", 24.hours.ago).count
  end

  def last_seen_at
    Ahoy::Event.where(user_id: id).order(time: :desc).first&.time || created_at
  end

  def after_confirmation
    enqueue_search_embedding
    PostInAdminChatJob.perform_later("📩 Email confirmed: #{email} for community #{community.slug}")
  end

  def send_login_pin
    pin = pins.create(code: SecureRandom.random_number(100000..999999), expires_at: 10.minutes.from_now)
    MemberMailer.login_pin(self, pin.code).deliver_now

    # recycle old pins
    pins.excluding(pins.order(created_at: :desc).limit(10)).destroy_all

    pin
  end

  def self.valid_email?(email)
    email = email.downcase.strip
    return false if email.blank?
    disposable = DisposableEmailService.disposable?(email)
    Rails.logger.debug { "Rejected disposable email address" } if disposable

    Member.exists?(email: email) || (Truemail.validate(email).result.success && !disposable)
  end

  def photo_url
    photo.attached? ? Rails.application.routes.url_helpers.rails_blob_url(photo, only_path: false, host: community.host) : nil
  end

  def as_json(options = {})
    attributes = [ :id, :email, :name, :permission, :slug, :created_at, :updated_at, :quarantined_at, :subscribed_at, :photo_url, :status, :locked_at ]
    methods = [ :photo_url, :status ]

    json = super(options.merge(only: attributes, methods: methods))

    # Include the HTML content of the about field
    json["about"] = about.present? ? about.to_s : nil
    json
  end

  private

  def find_and_set_person
    member_with_same_email = Member.unscoped.where(email: email).where.not(person_id: nil, id: id).first
    if member_with_same_email && person_id.nil?
      update_column(:person_id, member_with_same_email.person_id)
    end
  end

  def downcase_email
    self.email = email.downcase
  end

  def strip_whitespace
    self.name = name&.strip
    self.email = email&.strip
  end

  def move_friendly_id_error_to_title
    errors.add :title, *errors.delete(:friendly_id) if errors[:friendly_id].present?
  end

  def email_must_be_deliverable
    return if email.blank? || Rails.env.test?

    unless Member.valid_email?(email)
      errors.add(:email, I18n.t("communities.members.flash.create.invalid_email"))
    end
  end

  def prevent_admin_locking
    if admin? && locked_at_changed? && locked_at.present?
      # Automatically downgrade the permission level
      self.permission = :member
    end
  end

  def admin_permission_changed?
    permission_changed? && permission_was == "admin"
  end

  def ensure_at_least_one_admin_remains
    if community.members.where(permission: :admin).count <= 1
      errors.add(:permission, "cannot be revoked as this is the only admin in the community")
    end
  end
end
