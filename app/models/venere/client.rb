require 'typhoeus/adapters/faraday'
require 'savon'

class Venere::Client 

  class << self 

    def client(operation)
      Savon.client(wsdl: url + operation + '?wsdl', 
        env_namespace: :soapenv, 
        soap_header: soap_header, 
        namespace_identifier: :xhi,
        convert_request_keys_to: :none,
        endpoint: url + operation)
    end

   def url
      "https://b2b-uat.venere.com/xhi-1.0/services/"
    end

    def soap_header
      {
        'xhi:Authentication'=>
        {
          'xhi:UserOrgID' => 'hot5',
          'xhi:UserID'    => 'user_srv',
          'xhi:UserPSW'   => 'trident202'
        }
      }
    end

    def ping
      @ping_client ||= client('/XHI_Ping.soap')
      @ping_client.call(:xhi_ping_request, message_tag: :XHI_PingRQ, attributes: {echoData: 'pong?', msgEchoToken:"A01256"})
    end

    def hotel_availability(params={})
      return unless params[:hotel_ids]
      attributes = create_hotels_request params
      message = create_hotels_message params
      @hotel_client ||= client('/XHI_HotelAvail.soap')
      @hotel_client.call(:xhi_hotel_avail_request, 
        message_tag: :XHI_HotelAvailRQ, 
        attributes: attributes, 
        message: message)
    end
 
    def create_hotels_request(params)
      {
        start:                    params[:start_date],
        end:                      params[:end_date],
        numGuests:                params[:numGuests],
        numRooms:                 params[:numRooms],
        guestCountryCode:         params[:country_code],
        preferredPaymentCurrency: params[:currency_code]
      }
    end

    def create_hotels_message(params)
      # hotel_ids = params[:hotel_ids].join(' ')
      {
        'xhi:AvailQueryByProperty/' => "",
        :attributes! => {
          "xhi:AvailQueryByProperty/" => {
            "propertyIDs" => params[:hotel_ids]
          }
        }
      }
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

    def create_response(response)
      Nokogiri.XML(response.body)
    end



  end
end
