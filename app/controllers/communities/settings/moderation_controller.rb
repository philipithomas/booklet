class Communities::Settings::ModerationController < CommunitiesController
  layout "settings"

  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def show
  end

  def update
    @community.update(community_params)
    if @community.save
      redirect_to settings_moderation_path, notice: I18n.t("communities.settings.moderation.flash.update")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def community_params
    params.require(:community).permit(:open_ai_content_moderation_enabled, :open_ai_member_moderation_enabled)
  end
end
