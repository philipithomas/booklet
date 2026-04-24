class Communities::MentionsController < CommunitiesController
  def index
    authorize @community, policy_class: MentionsPolicy

    query = params[:query]
    limit = 5

    @members = if query.present?
      if @community.directory_enabled? || current_member.admin?
        @community.members.active
          .where("members.name ILIKE ?", "%#{query}%")
          .order(Arel.sql("CASE WHEN members.name ILIKE ? THEN 1 ELSE 2 END, members.name", "#{query}%"))
          .limit(limit)
      else
        # Only return members who have posted or replied hence have "de-anonymized" themselves
        @community.members.active
          .joins("LEFT JOIN posts ON posts.member_id = members.id")
          .joins("LEFT JOIN replies ON replies.member_id = members.id")
          .where("posts.id IS NOT NULL OR replies.id IS NOT NULL")
          .where("members.name ILIKE ?", "%#{query}%")
          .select("members.*, CASE WHEN members.name ILIKE '#{query}%' THEN 1 ELSE 2 END AS name_order")
          .order("name_order, members.name")
          .distinct
          .limit(limit)
      end
    else
      @community.members.active.limit(limit)
    end

    respond_to do |format|
      format.json
    end
  end
end
