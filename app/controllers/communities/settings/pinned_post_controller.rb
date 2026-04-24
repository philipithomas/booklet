class Communities::Settings::PinnedPostController < CommunitiesController
  layout "settings"

  before_action -> { authorize @community, policy_class: ::AdminPolicy }

  def update
    pinned_post = nil
    pinned_post = @community.posts.find_by(id: params[:pinned_post_id]) if params[:pinned_post_id].present?

    if params[:pinned_post_id].present? && pinned_post.nil?
      @community.errors.add(:pinned_post_id, "must be a valid post within the community")
      flash.now[:alert] = I18n.t("communities.settings.pinned_post.flash.update_error")
      return redirect_to posts_path, status: :see_other
    end

    @community.pinned_post = pinned_post
    pinned_post.touch if pinned_post.present?

    if @community.save
      respond_to do |format|
        format.turbo_stream do
          render :update, status: :ok
        end
        format.html do
          flash[:notice] = if pinned_post.present?
            I18n.t("communities.settings.pinned_post.flash.pinned")
          else
            I18n.t("communities.settings.pinned_post.flash.unpinned")
          end
          redirect_to posts_path, status: :see_other
        end
      end
    else
      flash.now[:alert] = I18n.t("communities.settings.pinned_post.flash.update_error")
      redirect_to posts_path, status: :see_other
    end
  end
end
