class MarketingController < ApplicationController
  layout "whole_page"
  def home
    render plain: "Booklet", status: 200 unless Rails.env.development?
  end

  def app_home
    redirect_to "#{request.protocol}#{Rails.configuration.marketing_host}#{[ 80, 443 ].include?(request.port) ? "" : ":#{request.port}"}", allow_other_host: true
  end
end
