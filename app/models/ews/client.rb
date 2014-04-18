require 'typhoeus/adapters/faraday'

class EWS::Client 

  class << self 

    def ews_key
      "fd8j99vktnpnq6y86uczm8sx"
    end

    def url
       "http://ews.expedia.com/wsapi/rest/hotel/v1/search?key=#{ews_key}"
    end

    def http
      FaradayService.http(url)
    end

    def post_hotel_availability(params={})
      parse_response(http.post(url, params))
    end

    def get_hotel_availability(params={})
      parse_response(http.get(url, params))
    end

    def parse_response(response)
      JSON.parse response.body if response
    end
  end
end
