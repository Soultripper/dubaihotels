require 'typhoeus/adapters/faraday'

class Agoda::Feeds 

  class << self 

    def url
       "http://xml.agoda.com/datafeeds/Feed.asmx/GetFeed"
    end

    def http
      Faraday.new(url: url) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.options[:nosignal] = true
        faraday.request  :retry,   3   # times
        faraday.request  :url_encoded             # form-encode POST params
        faraday.options[:timeout] = 60
        faraday.options[:open_timeout] = 2  
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.adapter  :my_typhoeus
      end
    end


    def hotels(params={})
      parse_response(http.get(url + '/bookings.getHotels', params))
    end

    def continents(params={})
      parse_response(http.get(feed_url(1), params))
    end

    def countries(params={})
      parse_response(http.get(feed_url(2), params))
    end

    def cities(params={})
      parse_response(http.get(feed_url(3), params))
    end

    def neighbourhoods(params={})
      parse_response(http.get(feed_url(4), params))
    end

    def regions(params={})
      parse_response(http.get(feed_url(21), params))
    end

    def parse_response(response)
      Nokogiri.XML(response.body)
    end

    def feed_url(feed_id)
      url + "?feed_id=#{feed_id}&apikey=72456eb0-9a1d-45ae-bb16-0b02d5ee6b2b"
    end
  end
end
