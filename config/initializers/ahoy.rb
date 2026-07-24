class Ahoy::Store < Ahoy::DatabaseStore
end

# Geocoding requires the local GeoLite2 database (see config/initializers/geocoder.rb)
Ahoy.geocode = File.exist?(Rails.root.join("config/data/GeoLite2-City.mmdb"))
Ahoy.job_queue = :low
Ahoy.user_method = :current_member
Ahoy.cookies = true
Ahoy.exclude_method = lambda do |_controller, request|
  request.host == Rails.configuration.cdn_host or request.path == "/favicon.ico"
end
Ahoy.server_side_visits = :when_needed
