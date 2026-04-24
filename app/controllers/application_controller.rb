class ApplicationController < ActionController::Base
  after_action :track_action

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :member_not_authorized

  include Pagy::Backend

  before_action do
    I18n.locale = "en-US" # Or whatever logic you use to choose.
  end
  before_action :store_user_location!, if: :storable_location?
  before_action :store_email_from_token
  skip_before_action :track_ahoy_visit, if: :health_check_route?

  skip_before_action :track_unverified_request, if: :pay_route?

  include SetPlatform

  AUTOTRACK_EVENT = "autotrack"
  def track_action
    return if request.get? || request.head? || request.options?

    ahoy.track AUTOTRACK_EVENT, request.path_parameters.merge({
      url: request.original_url,
      method: request.method,
      canonical_url: request.original_url.split("?").first,
      host: request.host,
      community: @community ? @community.id : nil,
      post: @post ? @post.id : nil
    })
  end

  def current_member
    @current_member ||= super.tap do |member|
      if member
        @current_member ||= super && Member.includes(:community).with(photo_attachment: [ blob: [ variant_records: { image_attachment: :blob } ] ]).find(@current_member.id) end
    end
  end

  def paywall_network_plan
    return if Rails.configuration.solo_mode
    return if @community&.payment_processor&.subscribed?

    redirect_to settings_subscription_path, notice: I18n.t("communities.settings.subscription.flash.network_paywall")
  end

  private

  def pay_route?
    request.path.starts_with?("/pay/")
  end

  def set_community
    if Rails.configuration.solo_mode
      @community = Community.with_all_rich_text.with_attached_logo.with_attached_logo_for_dark_background.with_attached_icon.first
      return
    end

    Rails.logger.debug "REQUEST HOST: #{request.host}"
    return set_community_from_subdomain if app_subdomain?
    set_community_from_host
  end

  def set_community!
    set_community
    raise ActiveRecord::RecordNotFound unless @community
  end

  def redirect_if_host_changed
    return unless @community
    if @domain.present?
      return if @domain.redirect_for_name.nil?
    end
    return if request.host.downcase == @community.host

    destination = URI.parse(request.url)
    destination.host = @community.host
    redirect_to String(destination), allow_other_host: true, status: :moved_permanently
  end

  def app_subdomain?
    request.host.ends_with?(".#{Rails.configuration.app_apex_host}")
  end

  def set_community_from_subdomain
    slug = request.host.chomp(".#{Rails.configuration.app_apex_host}").downcase
    @community = Community.with_all_rich_text.with_attached_logo.with_attached_logo_for_dark_background.with_attached_icon.friendly.find(slug, allow_nil: true)

    # Redirect if the slug is not canonical
    return unless @community
    return if @community.slug == slug

    destination = URI.parse(request.url)
    destination.host = @community.host
    redirect_to String(destination), allow_other_host: true, status: :moved_permanently
  end

  def set_community_from_host
    @domain = Domain.where(domain: request.host.downcase).first
    @community = Community.with_all_rich_text.with_attached_logo.with_attached_logo_for_dark_background.with_attached_icon.find(@domain.community_id) if @domain
  end

  def pundit_user
    current_member
  end

  def member_not_authorized
    if member_signed_in?
      flash[:alert] = I18n.t("pundit.not_authorized")
      redirect_to(request.referrer || posts_path)
      return
    end
    redirect_to new_member_session_path
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && !turbo_stream_request? && !request.path.start_with?("/passwordless") && !request.path.starts_with?("/notifications/") && !request.path.starts_with?("/verifications/")
  end

  def turbo_stream_request?
    request.headers["Accept"]&.include?("text/vnd.turbo-stream.html") || request.headers["Turbo-Frame"].present?
  end

  def store_user_location!
    store_location_for(:member, request.fullpath)
  end

  def store_email_from_token
    if params[:email_token].present?

      member = Member.find_by_email_signed_token(params[:email_token])
      session[:prefill_email] = member.email if member
    end
  end

  def health_check_route?
    request.path == "/health_check"
  end
end
