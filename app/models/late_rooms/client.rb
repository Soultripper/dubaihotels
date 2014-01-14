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
      Faraday.new(url: url) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.options[:nosignal] = true
        faraday.request  :retry,   3   # times
        faraday.request  :url_encoded             # form-encode POST params
        faraday.options[:timeout] = 20 
        faraday.options[:open_timeout] = 20  
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.adapter  :my_typhoeus
      end
    end

    def hotels(params={})
      create_response(http.get(url + '&rtype=3', params))
    end

    def create_response(response)
      Nokogiri.XML(response.body)
    end

  end
end
