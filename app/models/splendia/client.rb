require 'typhoeus/adapters/faraday'

class Splendia::Client 

  class << self 

    def partner_code
      "C287"
    end

    def url
      "http://shopbots.splendia.com/shopbots.php?partnercode=#{partner_code}"
      #"hotels=2&arrivaldate=2014-12-20&returndate=2014-12-21&lang=EN&currency=GBP&numguests=2"
    end

    def http
      FaradayService.http url
    end

    def hotels(params={})
      create_response(http.get(url, params))
    end

    def create_response(response)
      Nokogiri.XML(response.body)
    end

  end
end
