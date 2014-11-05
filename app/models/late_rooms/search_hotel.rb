module LateRooms
  class SearchHotel < LateRooms::Search

    attr_reader :ids, :responses

    def self.for_availability(hotel_id, search_criteria, options={})
      new(search_criteria, [hotel_id]).for_availability(options)
    end

    def for_availability(options={})
      params = search_params.merge(hotel_params)
      create_list_response LateRooms::Client.hotels(params)
    end


    def hotel_params(custom_ids=nil)
      {
        hids: (custom_ids || ids).join(','),
        rtype: 7
      }
    end

    def request(hotel_ids=nil, options={}, &success_block)
      HydraConnection.get LateRooms::Client.url, params: search_params.merge(hotel_params(hotel_ids))
    end

  end
end
