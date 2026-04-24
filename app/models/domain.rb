# == Schema Information
#
# Table name: domains
#
#  id                :bigint           not null, primary key
#  apex              :boolean          default(FALSE)
#  domain            :string           not null
#  redirect_for_name :string
#  verified          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  community_id      :bigint           not null
#
# Indexes
#
#  index_domains_on_community_id  (community_id)
#  index_domains_on_domain        (domain) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
class Domain < ApplicationRecord
  before_save :downcase_domain
  before_destroy :destroy_on_fly
  belongs_to :community, touch: true
  audited associated_with: :community

  after_update_commit :post_verification_tasks, if: :saved_change_to_verified?

  VALID_DOMAIN_REGEX = /\A[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,10}\z/
  validates :domain, presence: true,
    format: { with: VALID_DOMAIN_REGEX },
    uniqueness: { case_sensitive: false }

  def self.register(community, host) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    raise "domains already set" if community.domains.length.positive?

    host = host.downcase.strip

    if Rails.env.development? && Domain.localhost_domain?(host)
      return Domain.register_development_domains(community, host)
    end

    service = FlyService.new
    response = service.add(host)

    if response.nil?
      raise "Error creating domain #{host} on Fly - response not received"
    end

    Domain.create!(
      community: community,
      domain: response["hostname"],
      verified: response["clientStatus"] == "Ready"
    )
  end

  LOCALHOST_DOMAINS = [ "lvh.me", "fuf.me", "fbi.com" ].freeze
  def self.localhost_domain?(domain)
    LOCALHOST_DOMAINS.include?(domain) || LOCALHOST_DOMAINS.any? { |ld| domain.ends_with?(".#{ld}") }
  end

  def self.register_development_domains(community, host)
    domain = Domain.create!(
      community: community,
      domain: host,
      verified: false,
      apex: LOCALHOST_DOMAINS.include?(host),
      redirect_for_name: nil
    )

    return unless domain.apex?

    Domain.create!(
      community: community,
      domain: "www.#{host}",
      verified: false,
      apex: false,
      redirect_for_name: host
    )
  end

  def update_verification_status
    return if verified

    if !Rails.env.production? && Domain.localhost_domain?(domain)
      update!(verified: true) if Rails.env.test?
      update!(verified: true) if (created_at < 10.seconds.ago) && Rails.env.development?
      return
    end

    service = FlyService.new
    response = service.find(domain)

    if response.blank?
      raise "Error reading domain #{domain} in Fly.io - response not received"
    end

    puts "Domain #{domain} status: #{response["certificate"]["clientStatus"]}"
    return if response["certificate"]["clientStatus"] != "Ready"

    begin
      liveness_check
    rescue => e
      Honeybadger.notify("Error checking liveness of #{domain} - #{e}")
      return
    end

    update!(verified: true)
  end

  private

  def downcase_domain
    self.domain = domain.downcase
  end

  def destroy_on_fly
    return if redirect_for_name.present?
    return if Rails.env.development? && Domain.localhost_domain?(domain)

    service = FlyService.new
    response = service.delete(domain)

    return if response.present?

    raise "Error deleting domain #{domain} in Fly.io - response not received"
  end

  def liveness_check
    url = URI("https://#{domain}/health")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    raise "Error checking liveness of #{domain} - code #{response.code} \"#{response.body}\"" unless response.code == "200"
  end

  def post_verification_tasks
    return unless verified
    return if community.unverified_domain?
    CommunityAdminMailer.domain_verified(community).deliver_later

    # TODO - Ping search engines if public
  end
end
