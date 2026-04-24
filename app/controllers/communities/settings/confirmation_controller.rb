class Communities::Settings::ConfirmationController < CommunitiesController
  layout "whole_page"
  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def show
  end
end
