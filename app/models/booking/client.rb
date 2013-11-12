class Booking::Client 

  class << self 

    def url
       "https://#{Booking::Config.username}:#{Booking::Config.password}@distribution-xml.booking.com/json"
    end

    def http
      Faraday.new(url: url) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.adapter  :typhoeus
      end
    end

    def hotels(params={})
      parse_response(http.get(url + '/bookings.getHotels', params))
    end
    
    def cities(params={})
      parse_response(http.get(url + '/bookings.getCities', params))
    end

    def regions(params={})
      parse_response(http.get(url + '/bookings.getRegions', params))
    end

    def region_hotels(params={})
      parse_response(http.get(url + '/bookings.getRegionHotels', params))
    end

    def countries(params={})
      parse_response(http.get(url + '/bookings.getCountries', params))
    end

    def get_hotel_availability(params={})
      parse_response(http.post(url + '/bookings.getHotelAvailability', params))
    end

    def get_block_availability(params={})
      parse_response(http.get(url + '/bookings.getBlockAvailability', params))
    end

    def parse_response(response)
      JSON.parse response.body if response
    end
  end
end
