class Communities::Members::ContactController < CommunitiesController
  layout "community"

  before_action :set_member
  before_action :authorize_member

  def new
  end

  def create
    verify_recaptcha!

    Ahoy::Event.create(name: "contact_form_submitted", properties: { member_id: @member.id, community_id: @community.id })

    respond_to do |format|
      format.html { render :create }
      format.turbo_stream { render :create }
    end
  end
  private

  def set_member
    @member = @community.members.friendly.find(params[:member_slug])
  end

  def authorize_member
    authorize @member || @community, :"#{action_name}?", policy_class: MemberContactPolicy
  end
end
