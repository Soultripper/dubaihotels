require 'typhoeus/adapters/faraday'

class LateRooms::Client 

  class << self 

    def partner_code
      "15182"
    end

    def url
      "http://xmlfeed.laterooms.com/index.aspx?aid=#{partner_code}"
    end

    def http
      FaradayService.http url
    end

    def hotels(params={})
      create_response(http.get(url + '&rtype=7', params))
    end

    def create_response(response)
      Nokogiri.XML(response.body)
    end

  end
end
