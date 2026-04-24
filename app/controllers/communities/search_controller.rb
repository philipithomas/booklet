class Communities::SearchController < CommunitiesController
  layout "community"
  before_action -> { authorize @community, policy_class: SearchPolicy }

  def index
    @query = params[:q]
    if @query.blank?
      redirect_to posts_path and return
    end
  end

  def show
    query = params[:query]
    if query.blank?
      redirect_to search_index_path and return
    end

    @search = current_member.searches.create(query: query).embed

    member_name_matches = if @community.directory_enabled? || current_member.admin?
      @community.members.active
        .where("lower(members.name) LIKE ?", "%#{@search.query.downcase}%")
        .order(Arel.sql("CASE WHEN lower(members.name) LIKE ? THEN 1 ELSE 2 END, members.name", "#{@search.query.downcase}%"))
    else
      @community.members.active.where(id: 0)
    end

    allowed_content_types = [ "Post", "Reply" ]
    allowed_content_types << "Member" if @community.directory_enabled? || current_member.admin?

    vector_search_results = @search.chroma_query(
      results: 30,
      where: {
        content_type: { "$in" => allowed_content_types }
      }
    ).map(&:content).compact

    @results = (member_name_matches + vector_search_results).uniq
  end
end
