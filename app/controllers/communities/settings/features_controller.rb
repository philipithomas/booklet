class Communities::Settings::FeaturesController < CommunitiesController
  layout "settings"
  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def index
  end
end
