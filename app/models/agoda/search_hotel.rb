module Agoda
  class SearchHotel < Agoda::Search

    attr_reader :ids

    def self.for_availability(id, search_criteria, params={})
      new(search_criteria, id).for_availability(params)
    end

    def for_availability(options={})   
      params = {:Id => ids}.merge(search_params.merge(options)) 
      create_list_response Agoda::Client.get_availability(params)
    end

    def request(hotel_ids=nil, options={}, &success_block)
      request_params = {:Id => (hotel_ids || ids).join(',')}.merge(search_params.merge(options)) 
      xml_builder = Agoda::Client.request_builder(6, request_params)
      HydraConnection.post Agoda::Client.url, body: xml_builder.to_xml, headers: xml_headers
    end
    
  end

end
