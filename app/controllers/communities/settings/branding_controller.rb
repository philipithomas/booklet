class Communities::Settings::BrandingController < CommunitiesController
  layout "settings"

  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def show
  end

  def update
    @community.update(community_params)
    if @community.save
      redirect_to settings_branding_path, notice: I18n.t("communities.settings.branding.flash.update")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def community_params
    params.require(:community).permit(:name, :logo, :icon, :logo_for_dark_background, :brand_color, :slug)
  end
end
