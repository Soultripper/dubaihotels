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
      soap = soap_envelope(params) {by_property(params)}
      create_response(http.post(url + 'XHI_HotelAvail.soap', soap))
    end

    def geo_ids_search(params={})
      return unless params[:geo_ids]
      soap = soap_envelope(params) {by_geo_typology_category(params)}
      create_response(http.post(url + 'XHI_HotelAvail.soap', soap))
    end

    def geo_name_search(params={})
      return unless params[:country] and params[:city]
      soap = soap_envelope(params) {by_location(params)}
      create_response(http.post(url + 'XHI_HotelAvail.soap', soap))
    end

    def geo_city_zone_ids_search(params={})
      return unless params[:geo_ids]
      soap = soap_envelope(params) {by_geo_city_zone(params)}
      create_response(http.post(url + 'XHI_HotelAvail.soap', soap))
    end

    def circle_area(params={})
      return unless params[:latitude] and params[:longitude]
      soap = soap_envelope(params) {by_circle_area(params)}
      create_response(http.post(url + 'XHI_HotelAvail.soap', soap))
    end



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

    def soap_envelope(params, &block)
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
            #{yield block}
            <xhi:AvailResultFormat showDailyRates="false" showPropertyDetails="false" showLowestPriceOnly="false"  />
          </xhi:XHI_HotelAvailRQ>
        </soapenv:Body>
      </soapenv:Envelope>
      ]
      Nokogiri::XML(xml).to_xml
    end

    protected

    def by_property(params)
      %Q[<xhi:AvailQueryByProperty propertyIDs="#{params[:hotel_ids]}"/>]
    end

    def by_geo_typology_category(params)
      typology = "typology='#{params[:typology]}'" if params[:typology]
      category = "category='#{params[:category]}'" if params[:category]

      %Q[<xhi:AvailQueryByGeo geoIDs="#{params[:geo_ids]}" #{typology} #{category}/>]
    end

    def by_location(params)
      %Q[<xhi:AvailQueryByLocation countryName="#{params[:country]}" cityName="#{params[:city]}"/>]
    end

    def by_geo_city_zone(params)
      typology = "typology='#{params[:typology]}'" if params[:typology]
      category = "category='#{params[:category]}'" if params[:category]

      %Q[<xhi:AvailQueryByLocation cityZoneGeoIDs="#{params[:geo_ids]}" #{typology} #{category}/>]
    end

    def by_circle_area(params)
      radius = params[:radius] || 1
      %Q[
        <xhi:AvailQueryByCoordinatesCircle radius="#{radius}"> 
          <xhi:Coordinates lat="#{params[:latitude]}" long="#{params[:longitude]}" />
        </xhi:AvailQueryByCoordinatesCircle>
        ]
    end

  end
end
