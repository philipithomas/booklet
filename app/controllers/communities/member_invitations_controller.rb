class Communities::MemberInvitationsController < CommunitiesController
  layout "community"
  before_action :set_member, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize :member_invitation, :index?

    @members = @community.members.invited.order(invitation_sent_at: :desc)
  end

  # GET /members/invitation/new
  def new
    authorize :member_invitation, :new?

    @invited_member = Member.new
  end

  def create
    authorize :member_invitation, :create?

    emails = parse_emails(invitation_params[:email])
    errors = []
    @invited_members = []

    emails.each do |email|
      sanitized_email = email.strip.downcase
      invited_member = Member.safely_create_and_invite_member(@community, current_member, { email: sanitized_email })

      if invited_member.invited_to_sign_up? && !invited_member.confirmed?
        invited_member.broadcast_prepend_to "#{@community.id}_invitations", partial: "communities/member_invitations/invitation", locals: { member: invited_member }, target: "member_invitations"
        ahoy.track :member_invitation_created, community_id: @community.id, member_id: current_member.id, invited_member_id: invited_member.id
        @invited_members << invited_member
      else
        errors << sanitized_email
      end
    end

    respond_to do |format|
      if @invited_members.count > 0
        format.turbo_stream
        format.html { redirect_to member_invitations_path, notice: I18n.t("communities.member_invitations.flash.invited", count: @invited_members.count) }
      else
        @invited_member = Member.new
        format.turbo_stream { render "communities/member_invitations/failed_create", status: :unprocessable_entity }
        format.html { redirect_to member_invitations_path, notice: I18n.t("communities.member_invitations.flash.failed_create") }
      end
    end
  end

  def destroy
    authorize :member_invitation, :destroy?

    @member.destroy!

    # Synchronously remove the reply for the user who initiated the delete.
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to member_invitations_path, notice: I18n.t("communities.member_invitations.flash.revoked"), status: :see_other }
    end

    # Broadcast the removal of the reply to other users.
    @member.broadcast_remove_to "#{@community.id}_invitations"
  end

  private

  def invitation_params
    params.require(:member).permit(:email)
  end

  def authorize_invitation
    authorize :member_invitation, :invite?
  end

  def set_member
    @member = @community.members.invited.friendly.find(params[:slug])
  end

  def parse_emails(email_string)
    # Extract emails from the string
    email_string.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i)
  end
end
