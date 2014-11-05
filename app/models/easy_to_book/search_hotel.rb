module EasyToBook
  class SearchHotel < EasyToBook::Search

    attr_reader :ids

    def self.for_availability(id, search_criteria, params={})
      new(search_criteria, [id]).for_availability(params)
    end

    def for_availability(options={})   
      params = {:Hotellist => {:Hotelid => ids}}.merge(search_params.merge(options)) 
      create_list_response EasyToBook::Client.search_availability(params)
    end

    def request(hotel_ids=nil, options={}, &success_block)
      request_params = {:Hotellist=> {:Hotelid=> (hotel_ids || ids)}}.merge(search_params.merge(options)) 
      xml_builder = EasyToBook::Client.request_builder(:SearchAvailability, request_params)
      HydraConnection.post EasyToBook::Client.uri, body: xml_builder.to_xml, headers: xml_headers
    end

  end
end
