class CommunitiesController < ApplicationController
  prepend_before_action :set_community!, unless: :is_editor_request
  before_action :redirect_if_host_changed, :error_if_member_community_mismatch
  after_action :verify_authorized, except: :og_image

  def og_image
    return head(:unauthorized) unless @community

    png = Rails.cache.fetch("community-#{@community.id}-#{@community.updated_at.to_i}-og-img") do
      generate_og_image
    end

    expires_in 24.hours, public: true if @community.updated_at.to_i == params[:updated_at].to_i
    send_data(png, type: "image/png", disposition: "inline")
  end

  def confirmation_pending
    skip_authorization

    if current_member&.confirmed?
      return redirect_to posts_path, status: :see_other
    end
    render "devise/registrations/confirmation_pending", layout: "whole_page"
  end

  private

  def generate_og_image
    relative_html = render_to_string({
      template: "communities/og_image",
      layout: "application",
      locals: { community: @community, request: request }
    })

    grover = Grover.new(
      Grover::HTMLPreprocessor.process(relative_html, "#{request.base_url}/", request.protocol)
    )

    grover.to_png
  end

  def is_editor_request
    # The editor panel only exists in multiuser mode; in solo mode every host
    # (including editor_host) is the apex host, so this must not match there.
    return false unless Rails.configuration.multiuser_mode

    request.host == Rails.configuration.editor_host and (request.path == "/" || request.path.start_with?("/editors/"))
  end

  def error_if_member_community_mismatch
    return unless member_signed_in?
    return if @community.blank?

    raise "Member community mismatch" if current_member.community_id != @community.id
  end
end
