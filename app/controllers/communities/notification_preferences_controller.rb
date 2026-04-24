class Communities::NotificationPreferencesController < CommunitiesController
  before_action :skip_authorization
  before_action :set_member_from_token
  skip_before_action :verify_authenticity_token

  layout "whole_page"

  def show
    redirect_to settings_notifications_path if member_signed_in? && (current_member == @member)
  end

  def update
    if @member.update(member_params)
      redirect_to notification_preference_path(token: params[:token]), notice: I18n.t("communities.settings.notifications.flash.update")
    else
      render :show, status: :unprocessable_entity
    end
  end

  def list_unsubscribe
    field = params[:field]

    if request.post? && field.present? && @member.respond_to?(field) && field.start_with?("notify_") && field.end_with?("_email")
      @member.update(field => false)
      Rails.logger.info "List-Unsubscribe header was called for #{field}"
      render plain: "unsubscribed", status: :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def set_member_from_token
    @member = @community.members.find_by_email_signed_token(params[:token])
    raise ActionController::RoutingError.new("Not Found") unless @member
  end

  def member_params
    permitted_attributes = [ :notify_new_posts_email, :notify_mentions_email, :notify_newsletter_email ]
    params.require(:member).permit(permitted_attributes)
  end
end
