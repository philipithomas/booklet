class Communities::Settings::FeatureController < CommunitiesController
  layout "settings"
  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  include Wicked::Wizard

  steps :directory, :email_visibility

  def show
    render_wizard(nil, layout: "settings")
  end

  def update
    case step
    when :directory
      @community.directory_enabled = params["community"]["directory_enabled"] == "1"
    when :email_visibility
      @community.email_visibility = params["community"]["email_visibility"]
    end

    if @community.save
      redirect_to settings_features_path, notice: I18n.t("communities.settings.features.flash.saved")
    else
      render_wizard(nil, layout: "settings", status: :unprocessable_entity)
    end
  end
end
