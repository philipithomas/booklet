class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = true
Ahoy.job_queue = :low
Ahoy.user_method = :current_member
Ahoy.cookies = true
Ahoy.exclude_method = lambda do |_controller, request|
  request.host == Rails.configuration.cdn_host or request.path == "/favicon.ico"
end
Ahoy.server_side_visits = :when_needed
