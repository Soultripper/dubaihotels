require 'typhoeus/adapters/faraday'
require 'savon'

class Venere::Client 

  class << self 

    MSG_VERSION = '1.00.004'
    

    def client(operation)
      Savon.client(wsdl: url + operation + '?wsdl', 
        headers: { "Accept-Encoding" => "gzip, deflate" },
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
      @ping_client ||= client('XHI_Ping.soap')
      @ping_client.call(:xhi_ping_request, message_tag: :XHI_PingRQ, attributes: {echoData: 'pong?', msgEchoToken:"A01256"})
    end

    def hotel_availability(params={})
      return unless params[:hotel_ids]
      soap = soap_envelope(params)
      create_response(http.post(url + 'XHI_HotelAvail.soap', soap))
    end

    # def hotel_availability(params={})
    #   return unless params[:hotel_ids]
    #   attributes = create_hotels_request params
    #   message = create_hotels_message params
    #   @hotel_client ||= client('XHI_HotelAvail.soap')
    #   results = @hotel_client.call(:xhi_hotel_avail_request, 
    #     message_tag: :XHI_HotelAvailRQ, 
    #     attributes: attributes, 
    #     message: message)
    #   create_response results
    # end
 

    # def create_hotels_message(params)
    #   {
    #     'xhi:AvailQueryByProperty/' => "",
    #     :attributes! => {
    #       "xhi:AvailQueryByProperty/" => {
    #         "propertyIDs" => params[:hotel_ids]
    #       }
    #     }
    #   }
    # end


    def http
      Faraday.new(url: url) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.headers['Content-Type'] = 'text/xml;charset=utf-8'
        faraday.options[:nosignal] = true
        faraday.request  :retry,   3   # times
        faraday.request  :url_encoded             # form-encode POST params
        faraday.options[:timeout] = 30 
        faraday.options[:open_timeout] = 30  
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        faraday.adapter  :my_typhoeus
      end
    end

    def create_response(response)
      Nokogiri.XML(response.body).remove_namespaces!
    end

    def create_hotels_request(params)
      {
        msgVersion:               MSG_VERSION,
        start:                    params[:start_date],
        end:                      params[:end_date],
        numGuests:                params[:numGuests],
        numRooms:                 params[:numRooms],
        guestCountryCode:         params[:country_code],
        preferredPaymentCurrency: params[:currency_code]
      }
    end

    def soap_envelope(params)
    xml = %Q[
      <soapenv:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhi="http://www.venere.com/XHI" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
        <soapenv:Header>
          <xhi:Authentication>
            <xhi:UserOrgID>hot5</xhi:UserOrgID>
            <xhi:UserID>user_srv</xhi:UserID>
            <xhi:UserPSW>trident202</xhi:UserPSW>
          </xhi:Authentication>
        </soapenv:Header>
        <soapenv:Body>
          <xhi:XHI_HotelAvailRQ msgVersion="#{MSG_VERSION}" start="#{params[:start_date]}" end="#{params[:end_date]}" numGuests="#{params[:numGuests]}" numRooms="#{params[:numRooms]}" guestCountryCode="#{params[:country_code]}" preferredPaymentCurrency="#{params[:currency_code]}">
            <xhi:AvailQueryByProperty propertyIDs="#{params[:hotel_ids]}"/>
          </xhi:XHI_HotelAvailRQ>
        </soapenv:Body>
      </soapenv:Envelope>
      ]
      Nokogiri::XML(xml).to_xml
    end


  end
end
