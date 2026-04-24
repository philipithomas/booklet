class Communities::PostViewsController < CommunitiesController
  before_action :set_post

  def index
    authorize @post, :show?
    @members = View.preview_for_post(@post)
    @view_count = View.count_for_post(@post)
  end

  private

  def set_post
    @post = @community.posts.preloaded.friendly.find(params[:post_slug])
  end
end
