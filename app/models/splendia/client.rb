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
      Faraday.new(url: url) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.options[:nosignal] = true
        faraday.request  :retry,   3   # times
        faraday.request  :url_encoded             # form-encode POST params
        faraday.options[:timeout] = 20 
        faraday.options[:open_timeout] = 2  
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.adapter  :my_typhoeus
      end
    end

    def hotels(params={})
      create_response(http.get(url, params))
    end

    def create_response(response)
      Nokogiri.XML(response.body)
    end

  end
end
