class Communities::FollowsController < CommunitiesController
  before_action :set_follow, only: [ :unsubscribe, :confirm_unsubscribe ]
  before_action :skip_authorization
  layout "whole_page"

  def unsubscribe
    # The view will display the confirmation button to unsubscribe
    render :unsubscribe
  end

  def confirm_unsubscribe
    @follow.destroy!
    render :confirm_unsubscribe, status: :created
  end

  private

  def set_follow
    @follow = Follow.find_by_unsubscribe_signed_id!(params[:follow_signed_id])
    raise ActiveRecord::RecordNotFound unless @follow.community == @community
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path, alert: I18n.t("communities.follows.unsubscribe.not_found")
  end
end
