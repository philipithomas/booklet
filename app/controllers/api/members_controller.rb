class API::MembersController < APIController
  before_action :set_member, only: [ :show, :edit, :update, :destroy ]

  def index
    items = [ params[:items].to_i, 10, 100 ].sort.second

    @pagy, @members = pagy(@community.members, items: items, page: params[:page] || 1)
    render json: { members: @members.as_json, metadata: pagy_metadata(@pagy).slice(:count, :page, :last) }, status: :ok
  end

  def show
    render json: @member.as_json, status: :ok
  end

  def create
    @member = @community.members.new(new_member_params)

    if !Member.valid_email?(@member.email)
      Notable.track("Undeliverable email invited", "Community: #{@community.slug}, Invalid email: #{@member.email}, Inviter: API KEY #{@api_key.id}")
      @member.errors.add(:email, I18n.t("communities.members.flash.create.invalid_email"))
      return render json: { errors: @member.errors }, status: :unprocessable_entity
    end

    if @community.members.exists?(email: @member.email)
      return render json: { error: "email already exists" }, status: :conflict
    end

    new_member_params[:subscribed_at].present? ? direct_add_member : invite_member
  end

  def update
    @member.assign_attributes(update_member_params)
    if @member.save(validate: @member.confirmed_at?)
      @member.enqueue_moderation
      @member.enqueue_search_embedding
      render json: @member.as_json, status: :ok
    else
      render json: { errors: @member.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @member.destroy!

    render json: {}, status: :no_content
  end

  private

  def set_member
    begin
      @member = if params[:id].include?("@")
        @community.members.find_by!(email: params[:id].strip.downcase)
      else
        @community.members.friendly.find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Member not found" }, status: :not_found
      nil
    end
  end

  def new_member_params
    permitted_attributes = [ :name, :photo, :about, :email, :quarantined_at, :permission, :subscribed_at, :send_welcome ]

    params_hash = params.require(:member).permit(permitted_attributes)
    params_hash[:email] = params[:email].strip.downcase if params[:email]

    params_hash
  end

  def update_member_params
    if params[:member][:locked_at]&.is_a?(String)
      params[:member][:locked_at] = Time.current if params[:member][:locked_at].downcase == "true"
      params[:member][:locked_at] = nil if params[:member][:locked_at].downcase == "false" || params[:member][:locked_at].blank?
    end

    params.require(:member).permit([ :name, :photo, :about, :locked_at, :quarantined_at, :locked_at ])
  end

  def invite_member
    invited_member_count = @community.members_invited_in_last_24_hours
    if invited_member_count >= 1000
      return render json: { error: "invitation limit reached" }, status: :unprocessable_entity
    end

    @member = @community.members.invite!(new_member_params.merge(source: :invited))
    @community.member_invited!(nil, @member, current_visit)
    render json: @member.as_json, status: :created
  end

  def direct_add_member
    if !@community.can_direct_add_member?(current_member)
      direct_added_count = @community.members_directly_added(current_member)
      Notable.track("Direct add limit reached", "Community: #{@community.slug}, Added members: #{direct_added_count}, Adder: #{current_member.id} (#{current_member.email})")
      @member.errors.add(:email, I18n.t("communities.members.flash.create.direct_add_limit_reached"))
      return render json: { error: "direct add limit reached" }, status: :unprocessable_entity
    end

    @member.invited_by = current_member

    activated = @member.name.present?
    @member.direct_added!(activated: activated)

    unless @member.save(validate: activated)
      render json: { errors: @member.errors }, status: :unprocessable_entity and return
    end

    @community.member_directly_added!(current_member, @member, current_visit)
    render json: @member.as_json, status: :created
  end
end
