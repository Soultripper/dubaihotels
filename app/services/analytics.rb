class Analytics

  class << self 
    def publish(key, data)
      return unless data and key
      add_geo_lookup(data[:request]) 
      Keen.publish key, data
    end

    def add_geo_lookup(request)
      return nil unless request and request[:remote_ip]
      loc = Geokit::Geocoders::IpGeocoder.geocode(request[:remote_ip])
      request[:location] = {
          latitude: loc.lat,
          longitude: loc.lng,
          full_address: loc.full_address,
          address: loc.street_address,
          address2: loc.sub_premise,
          city: loc.city,
          province: loc.province,
          district: loc.district,
          state: loc.state,
          post_code: loc.zip,
          country_code: loc.country_code
      } if loc and loc.success
    end
  end

end