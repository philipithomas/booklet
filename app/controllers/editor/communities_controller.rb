class Editor::CommunitiesController < EditorController
  layout "editor"

  def index
    @pagy, @communities = pagy(Community.left_joins(:members).merge(Member.active).group(:id).order("count(members.id) desc"), items: 36)
  end

  def show
    @community = Community.friendly.find(params[:slug])
    @active_member_count = @community.members.active.count
    @invited_member_count = @community.members.invited.count
  end
end
