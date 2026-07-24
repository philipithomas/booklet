class EditorMailer < ApplicationMailer
  default from: -> { ActionMailer::Base.email_address_with_name(Rails.configuration.support_email, "Booklet") },
    to: -> { Rails.configuration.admin_email }

  def new_community(community)
    @community = community
    subject = "New community: #{@community.name} (#{@community.host})"
    headers["Message-ID"] = message_id_for_community(@community)

    mail subject: subject, reply_to: @community.email do |format|
      format.html { render layout: "mail/transactional" }
    end
  end

  def new_invitation(member)
    @member = member
    @community = @member.community
    headers["Message-ID"] = message_id_for_community(@community)
    subject = "New invitation: #{member.email} to #{member.community.name} (#{member.community.host})"

    mail subject: subject do |format|
      format.html { render layout: "mail/transactional" }
    end
  end

  private

  def message_id_for_community(community)
    "<community-#{community.id}@#{community.host}>"
  end
end
