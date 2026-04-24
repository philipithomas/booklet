class Editor::RepliesController < EditorController
  layout "editor"

  def index
    if params[:post_id]
      @post = Post.find(params[:post_id])
      @pagy, @replies = pagy(Reply.where(post: @post).order(created_at: :desc), items: 36)
    elsif params[:community_id]
      @community = Community.find(params[:community_id])
      @pagy, @replies = pagy(Reply.joins(:post).where(posts: { community_id: @community.id }).order(created_at: :desc), items: 36)
    else
      @pagy, @replies = pagy(Reply.order(created_at: :desc).all, items: 36)
    end
  end

  def show
    @reply = Reply.find(params[:id])
    @post = @reply.post
    @community = @post.community
    render "communities/replies/show", layout: "community"
  end
end
