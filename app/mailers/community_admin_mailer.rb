class CommunityAdminMailer < ApplicationMailer
  layout "mail/transactional"

  def domain_verified(community)
    @community = community
    admins = community.members.active_admins

    raise "No admins for #{community.host}" if admins.count.zero?

    admins.each do |admin|
      mail(to: admin.email, subject: I18n.t("emails.community_admin_mailer.domain_verified.subject", host: community.host),
        bcc: Rails.configuration.support_email, reply_to: Rails.configuration.support_email)
    end
  end
end
