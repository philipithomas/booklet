class Communities::EmailLogoController < CommunitiesController
  before_action :skip_authorization
  skip_before_action :verify_authenticity_token
  skip_before_action :track_ahoy_visit
  skip_before_action :track_unverified_request
  skip_after_action :track_action

  def show
    height = params[:height] || 64
    logo = @community.logo
    render plain: "Not Found", status: :not_found and return unless logo.attached?

    response.headers["Cache-Control"] = "public, max-age=86400"

    if logo.content_type == "image/svg+xml"

      image = Vips::Image.svgload_buffer(logo.download)
      image = image.resize(height.to_f / image.height)
      png_data = image.write_to_buffer(".png")

      send_data png_data, type: "image/png", disposition: "inline"
    else
      send_data logo.variant(resize_to_limit: [ nil, 64 ]).processed.download, type: "image/png", disposition: "inline"
    end
  end
end
