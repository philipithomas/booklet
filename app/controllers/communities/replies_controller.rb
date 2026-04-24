class Communities::RepliesController < CommunitiesController
  layout "community"
  before_action :set_post
  before_action :set_reply, only: [ :edit, :update, :destroy, :show ]

  def show
    authorize @reply
  end

  def index
    authorize @post, policy_class: ReplyPolicy
    @pagy, @replies = pagy(@post.replies.feed_for(current_member), items: 12)

    respond_to do |format|
      format.html
      format.turbo_stream if @pagy.page > 1
    end
  end

  def create
    authorize @post, policy_class: ReplyPolicy
    @reply = @post.replies.new(reply_params)
    @reply.member = current_member
    if @reply.save
      respond_to do |format|
        format.turbo_stream { }
        format.html { redirect_to post_path(@post), notice: I18n.t("communities.replies.flash.created") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render "communities/replies/failed_create", status: :unprocessable_entity }
        format.html { redirect_to post_path(@post), alert: I18n.t("communities.replies.flash.failed_create") }
      end
    end
  end

  def edit
    authorize @reply
  end

  def update
    authorize @reply

    if @reply.update(reply_params)
      @reply.enqueue_moderation
      @reply.enqueue_search_embedding

      # Synchronously update the reply for the user who initiated the action.
      respond_to do |format|
        format.turbo_stream unless @reply.saved_change_to_quarantined_at?
        format.html { redirect_to post_path(@reply.post), notice: I18n.t("communities.replies.flash.updated") }
      end

    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @reply

    # Destroy the reply from the database.
    @reply.destroy!

    # Synchronously remove the reply for the user who initiated the delete.
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to community_post_path(@reply.post.community, @reply.post), notice: I18n.t("communities.replies.flash.destroyed"), status: :see_other }
    end
  end

  private

  def set_post
    @post = @community.posts.preloaded.friendly.find(params[:post_slug])
  end

  def set_reply
    # Use the `preloaded` scope when fetching the reply
    @reply = @post.replies.preloaded.friendly.find(params[:slug])
  end

  def reply_params
    return params.require(:reply).permit(:body, :quarantined_at) if current_member&.manager_or_admin?
    params.require(:reply).permit(:body)
  end
end
