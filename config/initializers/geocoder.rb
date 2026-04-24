Geocoder.configure(
  ip_lookup: :geoip2,
  geoip2: {
    file: "config/data/GeoLite2-City.mmdb"
  }
)
