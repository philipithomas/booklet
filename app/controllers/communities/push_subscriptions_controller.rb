class Communities::PushSubscriptionsController < CommunitiesController
  def create
    authorize PushSubscription
    subscription = current_member.push_subscriptions.find_or_initialize_by(endpoint: params[:endpoint])
    subscription.assign_attributes(
      p256dh: params[:p256dh],
      auth: params[:auth],
      subscribed: true,
      ahoy_visit: current_visit,
      user_agent: request.user_agent
    )
    subscription.save!
    if subscription.persisted?
      render json: { message: "Subscription successfully saved" }, status: :ok
    else
      render json: { error: "Error in storing subscription" }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @post

    @post.destroy!
    flash[:notice] = I18n.t("communities.posts.flash.destroyed")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.redirect(posts_path)
      end
      format.html { redirect_to posts_path, status: :see_other }
    end
  end

  def follow
    authenticate_member!

    @post.follows.find_or_create_by(member: current_member)
    respond_to do |format|
      format.html { redirect_to post_path(@post) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("follow-button", partial: "components/post/follow_button", locals: { post: @post, following: true })
      end
    end
  end

  def unfollow
    authenticate_member!

    follow = @post.follows.find_by(member: current_member)
    follow&.destroy!
    respond_to do |format|
      format.html { redirect_to post_path(@post) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("follow-button", partial: "components/post/follow_button", locals: { post: @post, following: false })
      end
    end
  end

  def og_image
    authorize @post, :show?, policy_class: PostPolicy

    png = Rails.cache.fetch("post-#{@post.id}-#{@post.updated_at.to_i}-og-img") do
      generate_og_image
    end

    expires_in 24.hours, public: true if @post.updated_at.to_i == params[:updated_at].to_i
    send_data(png, type: "image/png", disposition: "inline")
  end

  private

  def set_post
    slug = params[:slug] || params[:post_slug]
    @post = @community.posts.preloaded.friendly.find(slug)
    if request.get? && slug != @post.slug
      redirect_to post_path(@post), status: :found
    end
  end

  def post_params
    return params.require(:post).permit(:title, :body, :published_at, :quarantined_at) if current_member&.manager_or_admin?
    params.require(:post).permit(:title, :body, :published_at)
  end

  def enqueue_view
    CreateViewJob.perform_later(current_member&.id, @post, current_visit&.id) if current_member
  end

  def generate_og_image
    relative_html = render_to_string({
      template: "communities/posts/og_image",
      layout: "application",
      locals: { community: @community, request: request, post: @post }
    })

    grover = Grover.new(
      Grover::HTMLPreprocessor.process(relative_html, "#{request.base_url}/", request.protocol)
    )

    grover.to_png
  end
end
