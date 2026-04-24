class FounderMailer < ApplicationMailer
  default from: -> { ActionMailer::Base.email_address_with_name(Rails.configuration.admin_email, "Booklet") }

  def welcome(member)
    @member = member
    @community = member.community
    subject = @community.name

    mail subject: subject, to: @member.email
  end

  def frctnl_welcome(member)
    @member = member
    @community = member.community
    subject = @community.name

    mail subject: subject, to: @member.email
  end
end
