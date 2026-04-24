class Communities::Settings::HostingController < CommunitiesController
  layout "settings"
  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def show
  end

  def update
    if @community.update(community_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_hosting_path, notice: I18n.t("communities.settings.hosting.flash.update") }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @community.domains.map(&:destroy)
    @community.reload
    redirect_to settings_hosting_path, notice: I18n.t("communities.settings.hosting.flash.update")
  end

  private

  def community_params
    params.require(:community).permit(:slug, :visibility, :signups)
  end
end
