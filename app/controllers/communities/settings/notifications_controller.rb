class Communities::Settings::NotificationsController < CommunitiesController
  layout "settings"
  before_action :skip_authorization
  before_action :authenticate_member!
  before_action :set_member

  def show
  end

  def update
    if @member.update(member_params)
      redirect_to settings_notifications_path, notice: I18n.t("communities.settings.notifications.flash.update")
    else
      render :show, status: unprocessable_entity
    end
  end

  private

  def set_member
    @member = current_member
  end

  def member_params
    permitted_attributes = [ :notify_new_posts_email, :notify_new_posts_push, :notify_mentions_email, :notify_mentions_push, :notify_newsletter_email, :notify_newsletter_push ]
    params.require(:member).permit(permitted_attributes)
  end
end
