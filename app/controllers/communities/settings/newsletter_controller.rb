class Communities::Settings::NewsletterController < CommunitiesController
  layout "settings"

  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def show
    @newsletter_days = @community.newsletter_days
  end

  def update
    # Convert selected days into a bitmask
    selected_days_bitmask = (params.dig(:notifications, :newsletter_days) || []).map { |day| NewsletterDaysBitmask::DAYS[day] }.sum
    @community.update(newsletter_days_bitmask: selected_days_bitmask)

    redirect_to settings_newsletter_path, notice: I18n.t("communities.settings.newsletter.flash.update")
  end
end
