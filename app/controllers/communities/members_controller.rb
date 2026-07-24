class Communities::MembersController < CommunitiesController
  layout "community"

  before_action :set_member, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_member
  before_action :check_admin_limit, only: [ :create, :update ]

  def index
    @pagy, @members = pagy_countless(@community.members.listed, items: 30)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def index_all
    @pagy, @members = pagy_countless(@community.members.order(created_at: :desc), items: 30)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @member = Member.new
  end

  def create
    @member = @community.members.new(member_params.except(:confirmed_at))
    if @member.email.present?
      existing_member = @community.members.find_by(email: @member.email)
      if existing_member
        redirect_to member_path(existing_member), alert: I18n.t("communities.members.flash.create.already_exists") and return
      end

      # need to validate separately because member not always validated before saving
      if !Member.valid_email?(@member.email)
        Notable.track("Undeliverable email invited", "Community: #{@community.slug}, Invalid email: #{member_params[:email]}, Inviter: #{current_member.id} (#{current_member.email})")
        @community.member_invited!(current_member) # still track for rate limiting
        @member.errors.add(:email, I18n.t("communities.members.flash.create.invalid_email"))
        render :new, status: :unprocessable_entity and return
      end

      (member_params[:subscribed_at] == "1") ? direct_add_member : invite_member
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @member.assign_attributes(member_params)

    if @member.save(validate: @member.confirmed_at?)
      @member.enqueue_moderation
      @member.enqueue_search_embedding
      redirect_to member_path(@member), notice: I18n.t("communities.members.flash.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to all_members_path, notice: I18n.t("communities.members.flash.destroy.success") }
    end
  end

  private

  def set_member
    @member = @community.members.friendly.find(params[:slug])
  end

  def authorize_member
    authorize @member || @community, :"#{action_name}?", policy_class: MemberPolicy
  end

  def member_params
    permitted_attributes = [ :name, :photo, :about, :locked_at, :confirmed_at, :email ]
    if current_member&.admin?
      permitted_attributes += [ :quarantined_at, :permission, :subscribed_at, :send_welcome ]
    end
    params_hash = params.require(:member).permit(permitted_attributes)
    params_hash[:email] = params[:member][:email].strip.downcase if params[:member][:email]
    params_hash[:send_welcome] = params[:member][:send_welcome] == "1" if params[:member][:send_welcome]
    params_hash
  end

  def check_admin_limit
    return if @community.active_subscription?

    if params[:member][:permission] == "admin" && @community.members.where(permission: "admin").count >= 2
      redirect_to settings_subscription_path, alert: I18n.t("communities.members.flash.admin_limit_reached")
    end
    nil
  end

  def invite_member
    invited_member_count = @community.members_invited_in_last_24_hours
    if invited_member_count >= 1000
      Notable.track("Invitation limit reached", "Community: #{@community.slug}, Invited members: #{invited_member_count}, Inviter: #{current_member.id} (#{current_member.email})")
      redirect_to new_member_path, alert: I18n.t("communities.members.flash.create.invitation_limit_reached", count: invited_member_count)
    end

    @member = @community.members.invite!(member_params.merge(source: :invited), current_member)
    @community.member_invited!(current_member, @member, current_visit)
    redirect_to member_path(@member), notice: I18n.t("communities.members.flash.create.invited")
  end

  def direct_add_member
    if !@community.can_direct_add_member?(current_member)
      direct_added_count = @community.members_directly_added(current_member)
      Notable.track("Direct add limit reached", "Community: #{@community.slug}, Added members: #{direct_added_count}, Adder: #{current_member.id} (#{current_member.email})")
      @member.errors.add(:email, I18n.t("communities.members.flash.create.direct_add_limit_reached"))
      return render :new, status: :unprocessable_entity
    end

    @member.invited_by = current_member

    activated = @member.name.present?
    @member.direct_added!(activated: activated)

    unless @member.save(validate: activated)
      render :new, status: :unprocessable_entity and return
    end

    @community.member_directly_added!(current_member, @member, current_visit)

    redirect_to member_path(@member), notice: activated ? I18n.t("communities.members.flash.create.activated") : I18n.t("communities.members.flash.create.subscribed")
  end

  def import_members
    raise NotImplementedError
  end
end
