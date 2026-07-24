class Editor::PostsController < EditorController
  layout "editor"

  def index
    if params[:community_id]
      @community = Community.find(params[:community_id])
      @pagy, @posts = pagy(Post.published.where(community: @community).order(published_at: :desc), items: 36)
    else
      @pagy, @posts = pagy(Post.published.order(published_at: :desc).all, items: 36)
    end
  end

  def show
    @post = Post.find(params[:id])
    @community = @post.community
    render "communities/posts/show", layout: "community"
  end
end
