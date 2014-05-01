class Analytics

  class << self 

    
    def publish(key, data)
      return unless data and key
      Thread.new do 
        add_geo_lookup(data[:request]) 
        Keen.publish key, data
        Log.debug "Published analytic: #{key}"
      end
    end

    def clickthrough(options)
      hotel = options[:hotel]
      data = {
        provider: options[:provider],
        search: options[:search_criteria],
        offer: options[:offer],
        hotel: {
          id: hotel.id,
          name: hotel.name,
          address: hotel.address,
          city: hotel.city, 
          country_code: hotel.country_code,
          star_rating: hotel.star_rating,
          slug: hotel.slug
          },
        request: options[:request_params]
      }
      HotelScorer.score hotel, :clickthrough
      publish :clickthrough, data
    end

    def search(options)
      data = {
        search: options[:search_criteria],
        location: options[:location],
        request: options[:request_params]
      }
      publish :search, data
    end


    def hotel_seo(options)
      hotel = options[:hotel]
      data = {
        search: options[:search_criteria],
        hotel: {
          id: hotel.id,
          name: hotel.name,
          address: hotel.address,
          city: hotel.city, 
          country_code: hotel.country_code,
          star_rating: hotel.star_rating,
          slug: hotel.slug
          },
        request: options[:request_params]
      }
      HotelScorer.score hotel, :hotel_seo
      publish :hotel_seo, data
    end

    def more_hotels(options)
      data = {
        search: options[:search_criteria],
        location: options[:location],
        request: options[:request_params],
        count: options[:count]
      }
      publish :more_hotels, data
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