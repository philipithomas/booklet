# Geocoding requires the local GeoLite2 database (see config/initializers/geocoder.rb)
AuthTrail.geocode = File.exist?(Rails.root.join("config/data/GeoLite2-City.mmdb"))
AuthTrail.job_queue = :low

AuthTrail.transform_method = lambda do |data, request|
  data[:community_id] = request.params[:member][:community_id] if request.params[:member]
  data[:host] = request.host
end

# exclude certain attempts from tracking
# AuthTrail.exclude_method = lambda do |data|
#   data[:identity] == "capybara@example.org"
# end
