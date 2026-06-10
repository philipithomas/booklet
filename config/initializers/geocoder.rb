# IP geolocation for visit/login analytics (Ahoy and AuthTrail).
#
# Requires a MaxMind GeoLite2 City database, which cannot be redistributed
# with this repo. Download it with a free MaxMind license key from
# https://dev.maxmind.com/geoip/geolite2-free-geolocation-data and place it
# at config/data/GeoLite2-City.mmdb. Geocoding is skipped when the file is
# absent.

geolite_db = Rails.root.join("config/data/GeoLite2-City.mmdb")

if File.exist?(geolite_db)
  Geocoder.configure(
    ip_lookup: :geoip2,
    geoip2: {
      file: geolite_db.to_s
    }
  )
end
