class RobotsController < ApplicationController
  before_action :set_community

  def show
    @public = @community&.visibility_public?

    respond_to :text

    @sitemap_url = "https://#{request.host}/sitemap.xml"

    expires_in 6.hours, public: true
  end
end
