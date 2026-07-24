class Communities::PostsController < CommunitiesController
  layout "community", except: [ :edit ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :follow, :unfollow, :og_image ]
  before_action :skip_authorization, only: [ :follow, :unfollow ]
  after_action :enqueue_view, only: [ :show ]

  def index
    authorize @community, policy_class: PostPolicy
    @pagy, @posts = pagy_countless(@community.posts.feed_for(current_member, @community), items: 18)

    respond_to do |format|
      format.html
      format.turbo_stream if @pagy.page > 1
    end
  end

  def recommended
    authorize @community, policy_class: PostPolicy
    @recommended_posts = DraftRecommendationService.new(current_member).call.shuffle # shuffling works with bucket caching to create more perceived recommendations
  end

  def show
    authorize @post

    @follow = @post.follows.find_by(member: current_member) if current_member
  end

  def edit
    authorize @post
    @other_drafts = @community.posts.drafts(current_member).where.not(id: @post.id)
    render :edit, layout: "drafter"
  end

  def update
    authorize @post

    if @post.published? && post_params[:published_at].nil?
      @post.errors.add(:base, "Cannot unpublish a published post")
      render :edit, status: :unprocessable_entity
      return
    end

    @post.assign_attributes(post_params)
    @post.slug = nil # Resets FriendlyID
    if @post.save(validate: @post.published?)
      @post.publish! if !@post.published? && params[:commit] == "publish"
      @post.enqueue_moderation if @post.published?
      @post.enqueue_search_embedding if @post.published?
      respond_to do |format|
        format.html {
          redirect_to @post.published? ? post_path(@post) : posts_path, notice: @post.published? ? I18n.t("communities.posts.flash.published") : I18n.t("communities.posts.flash.saved")
        }
        format.turbo_stream { } unless params[:commit] == "save" || @post.published?
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    authorize Post
    prompt = params[:s_prompt] ? Post.verify_signed_prompt(params[:s_prompt]) : nil

    if prompt
      @post = @community.posts.build(prompt: prompt, title: prompt)
    else
      unless params[:force_new]
        existing_draft = @community.posts.drafts(current_member).first
        if existing_draft
          redirect_to edit_post_path(existing_draft) and return
        end
      end
      @post = @community.posts.build
    end
    @post.member = current_member
    @post.save!(validate: false)
    redirect_to edit_post_path(@post)
  end

  def create
    authorize Post
    @post = @community.posts.new(post_params)
    @post.member = current_member

    respond_to do |format|
      if @post.save
        @post.publish!
        format.html { redirect_to post_path(@post), notice: I18n.t("communities.posts.flash.created") }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
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
      if request.path == edit_post_path(slug)
        redirect_to edit_post_path(@post), status: :found
      else
        redirect_to post_path(@post), status: :found
      end
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
