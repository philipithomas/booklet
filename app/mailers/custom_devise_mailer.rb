class CustomDeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers
  include DeviseInvitable::Mailer
  helper :application
  layout "mail/transactional"

  def confirmation_instructions(record, token, opts = {})
    set_community(record.community)
    super
  end

  def reset_password_instructions(record, token, opts = {})
    set_community(record.community)
    super
  end

  def invitation_instructions(record, token, opts = {})
    set_community(record.community)
    @community = record.community # assuming the invited User has an association to Community
    @inviter = record.invited_by # Devise Invitable provides 'invited_by' association

    @token = token

    devise_mail(record, :invitation_instructions, opts)
  end

  def subject_for(key)
    if key.to_s == "invitation_instructions"
      if @inviter.present?
        I18n.t("devise.mailer.#{key}.subject_with_inviter",
          community_name: @community.name,
          inviter_name: @inviter.name)
      else
        I18n.t("devise.mailer.#{key}.subject",
          community_name: @community.name)
      end
    else
      super
    end
  end
end
