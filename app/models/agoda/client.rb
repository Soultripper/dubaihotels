require 'typhoeus/adapters/faraday'

class Agoda::Client 

  class << self 

    def site_id
      1620684
    end

    def api_key
      "72456EB0-9A1D-45AE-BB16-0B02D5EE6B2B"
    end

    def wait_time
      15
    end

    def url
      "http://xml.agoda.com/xmlpartner/XmlService.svc/search_srv2"
      # "http://sandbox.xml.agoda.com/xmlpartner/XmlService.svc/search_srv2"
    end

    def http
      Faraday.new(url: url) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.headers['Content-Type'] = "application/xml; charset=utf-8"
        faraday.options[:nosignal] = true
        faraday.request  :retry,   1   # times
        faraday.options[:timeout] = 15 
        faraday.options[:open_timeout] = 2  
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        faraday.adapter  :my_typhoeus
      end
    end


    def search_availability(params)      
      create_response send_request(6, params)
    end

    def get_availability(params)      
      create_response send_request(4, params)  
    end



    def send_request(request_type, params)
      builder = request_builder(request_type, params)
      Log.info "Sending request to Agoda: #{builder.to_xml}"
      http.post(url, builder.to_xml)      
    end

    def create_response(response)
      Nokogiri.XML(response.body)
    end

    def request_builder(request_type, params)
      Nokogiri::XML::Builder.new do |xml|
        xml.AvailabilityRequestV2(siteid: site_id, apikey: api_key, async: false, waittime: wait_time, xmlns: "http://xml.agoda.com", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance") {
          xml.Type request_type

          params.each do |key, value| 
            xml.send key, value
          end 
        }
      end
    end

  end
end
