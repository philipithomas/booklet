# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/authtrail#geocoding
AuthTrail.geocode = true
AuthTrail.job_queue = :low

AuthTrail.transform_method = lambda do |data, request|
  data[:community_id] = request.params[:member][:community_id] if request.params[:member]
  data[:host] = request.host
end

# exclude certain attempts from tracking
# AuthTrail.exclude_method = lambda do |data|
#   data[:identity] == "capybara@example.org"
# end
