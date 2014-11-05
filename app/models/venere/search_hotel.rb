module Venere
  class SearchHotel < Venere::Search

    attr_reader :ids, :responses

    def self.for_availability(hotel_id, search_criteria, options={})
      new(search_criteria, [hotel_id]).for_availability(options)
    end

    def for_availability(options={})
      params = search_params.merge(hotel_params)
      create_list_response Venere::Client.hotel_availability(params)
    end

    def self.by_geo_ids(geo_ids, search_criteria, options={})
      new(search_criteria, [geo_ids]).by_geo_ids(options)
    end

    def self.by_geo_city_zone_ids(city_zone_ids, search_criteria, options={})
      new(search_criteria, [city_zone_ids]).by_geo_city_zone_ids(options)
    end

    def by_geo_ids(options={})
      params = search_params.merge(geo_id_params(options))
      create_list_response Venere::Client.geo_ids_search(params)
    end

    def by_geo_city_zone_ids(options={})
      params = search_params.merge(geo_id_params(options))
      create_list_response Venere::Client.geo_city_zone_ids_search(params)
    end

    def hotel_params(custom_ids=nil)
      {
        hotel_ids: (custom_ids || ids).join(' ')
      }
    end

    def geo_id_params(options=nil)
      {
        geo_ids: ids.join(' '),
        typology: options[:typology],
        category: options[:category]
      }
    end

    def request(hotel_ids=nil, options={}, &success_block)
      params = search_params.merge(hotel_params(hotel_ids || ids))
      soap_envelope = Venere::Client.soap_envelope(params)  {Venere::Client.by_property(params)}
      HydraConnection.post Venere::Client.url + 'XHI_HotelAvail.soap', body: soap_envelope, headers: xml_headers
    end

  end
end
