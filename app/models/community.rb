# frozen_string_literal: true

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
class Community < ApplicationRecord
  extend FriendlyId
  include Sluggable
  include BrandColorable
  include Initializeable
  include NewsletterDaysBitmask
  include Pusherable
  include Invitable
  include DirectAddable

  validates :name, presence: true, length: { maximum: 255 }
  validates :brand_color, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/ }
  friendly_id :name, use: %i[slugged history], slug_limit: 255

  validates :email, presence: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }, disposable_email: true # For stripe
  validate :email_must_be_deliverable

  validates :signups, presence: true
  validates :visibility, presence: true
  validates :newsletter_days_bitmask, inclusion: { in: 0..127 }, allow_nil: false

  enum visibility: { private: 0, public: 1, unlisted: 2 }, _prefix: :visibility
  enum signups: { invite_only: 0, open: 1 }, _prefix: :signups
  enum email_visibility: %w[open protected hidden].index_by(&:itself), _prefix: true

  has_many :members, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :messages, dependent: :destroy, class_name: "Ahoy::Message"
  has_many :posts, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :replies, through: :posts
  has_many :newsletters, dependent: :destroy
  belongs_to :pinned_post, class_name: "Post", optional: true
  has_many :api_keys, dependent: :destroy

  has_one_attached :logo, strict_loading: true
  has_one_attached :logo_for_dark_background, strict_loading: true
  has_one_attached :icon, strict_loading: true do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 960, 960, { crop: "attention" } ] # Must be multiple of 48 for Google
  end

  before_save :strip_whitespace

  audited
  has_associated_audits

  visitable :ahoy_create_visit

  pay_customer stripe_attributes: ->(pay_customer) { { metadata: { host: pay_customer.owner.host, community_id: pay_customer.owner.id } } }

  def pay_should_sync_customer?
    super || saved_change_to_slug?
  end

  def active_subscription?
    return true if Rails.configuration.solo_mode
    payment_processor&.subscribed?
  end

  #  after_save_commit :set_brand_color_from_logo

  VALID_SLUG_REGEX = /\A[a-z0-9]+(-[a-z0-9]+)*\z/
  validates :slug, presence: true, length: { minimum: 2, maximum: 255 },
    format: { with: VALID_SLUG_REGEX, message: "can only contain letters, numbers and '-'" },
    exclusion: { in: DISALLOWED_SLUGS },
    uniqueness: true

  after_create_commit -> {
    generate_vapid_keys
    PostInAdminChatJob.perform_later("[New community] #{name} #{url}")
  }

  def host
    @host ||= begin
      if Rails.configuration.solo_mode
        # Solo mode serves the single community on the apex host directly —
        # slug subdomains only exist in multiuser mode.
        Rails.configuration.base_host
      else
        custom_domain = domains.where(redirect_for_name: nil, verified: true).first
        custom_domain ? custom_domain.domain : "#{slug}.#{Rails.configuration.app_apex_host}"
      end
    end
  end

  def url
    scheme = Rails.env.production? ? "https" : "http"
    port = Rails.env.production? ? nil : ":3000"
    domain_host = host
    "#{scheme}://#{domain_host}#{port}/"
  end

  def to_param
    slug
  end

  def unverified_domain?
    domains.where(verified: false).any?
  end

  def generate_slug
    self.slug = name.parameterize(separator: "-").truncate(63, omission: "").downcase
    # Check if unique
    if Community.where(slug: slug).any? || DISALLOWED_SLUGS.include?(slug)
      self.slug = "#{slug}-#{SecureRandom.hex(4)}"
    end
  end

  def checkout_url(success_url, cancel_url) # rubocop:disable Metrics/MethodLength
    set_payment_processor :stripe
    payment_processor.customer
    checkout_session = payment_processor.checkout(
      mode: "subscription",
      line_items: [
        {
          price: ENV["STRIPE_PLAN_ID"],
          quantity: 1
        }
      ],
      automatic_tax: { enabled: false },
      cancel_url: cancel_url,
      success_url: success_url,
      allow_promotion_codes: true,
      billing_address_collection: "auto",
      payment_method_collection: "if_required",
      customer_update: {
        address: "auto",
        name: "auto"
      }
    )
    checkout_session.url
  end

  private

  def strip_whitespace
    self.name = name&.strip
  end

  def email_must_be_deliverable
    return if email.blank? || Rails.env.test?

    unless Member.valid_email?(email)
      errors.add(:email, :undeliverable, message: "is not deliverable")
    end
  end
end
