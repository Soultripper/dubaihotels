require 'typhoeus/adapters/faraday'
# require 'faraday_middleware'

class EasyToBook::Client 

  class << self 

    def config
      EasyToBook::Config.config
    end

    def uri
      config.uri
    end

    # def http
    #   http = Net::HTTP.new(uri.host,uri.port)
    # end


    def http
      Faraday.new(url: uri) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.headers['Content-Type'] = "application/xml; charset=utf-8"
        faraday.options[:nosignal] = true
        faraday.request  :retry,   3   # times
        faraday.options[:timeout] = 20 
        faraday.options[:open_timeout] = 20  
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        faraday.adapter  :my_typhoeus
      end
    end


    def search_availability(params)      
      create_response send_request(:SearchAvailability, params)
    end

    def get_availability(params)      
      create_response send_request(:GetHotelAvailability, params)  
    end

    def send_request(function_name, params)
      builder = request_builder(function_name, params)
      Log.info "Sending request to EasyToBook: #{builder.to_xml}"
      http.post(uri.path, builder.to_xml)      
    end

    def create_response(response)
      Nokogiri.XML(response.body)
    end

    # def response(request)
    #   http = Net::HTTP.new(uri.host,uri.port)
    #   response = http.post(uri.path,self.to_xml)
    #   Nokogiri.XML(response.body)
    # end

    def request_builder(function_name, params)
      Nokogiri::XML::Builder.new do |xml|
        xml.Easytobook {
          xml.Request(:target => config.env) {
            xml.Authentication(:username => config.username, :password => config.password) {
              xml.Function function_name
            }
            params.each do |key,value| 
              create_element xml, key, value
            end if params
          }
        }
      end
    end

    def create_element(xml, key, value)
      if key == :Hotellist
        xml.Hotellist {
          value[:Hotelid].each {|val| xml.Hotelid val }
        }
        # value.each {|val| create_element parent_xml, key, val}
        return
      end
      xml.send key, value
    end

  end
end
