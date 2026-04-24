class Editor::MembersController < EditorController
  layout "editor"

  def index
    if params[:community_id]
      @community = Community.find(params[:community_id])
      @pagy, @members = pagy(Member.where(community: @community).order(created_at: :desc), items: 36)
    elsif params[:email]
      @email = params[:email].strip.downcase
      @pagy, @members = pagy(Member.where(email: @email).order(created_at: :desc), items: 36)
    else
      @pagy, @members = pagy(Member.order(created_at: :desc).all, items: 36)
    end
  end

  def show
    @member = Member.find(params[:id])
    @community = @member.community
    render "communities/members/show", layout: "community"
  end
end
