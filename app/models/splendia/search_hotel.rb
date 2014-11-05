module Splendia
  class SearchHotel < Splendia::Search

    attr_reader :ids, :responses

    def self.for_availability(hotel_id, search_criteria, options={})
      new(search_criteria, [hotel_id]).search(options)
    end

    def search(options={})
      params = search_params.merge(hotel_params)
      create_list_response Splendia::Client.hotels(params)
    end

    def hotel_params(custom_ids=nil)
      {
        hotels: (custom_ids || ids).join(',')
      }
    end

    def request(hotel_ids=nil, options={}, &success_block)
      HydraConnection.get Splendia::Client.url, params: search_params.merge(hotel_params(hotel_ids))
    end

    def first_slice_size; 150; end

  end
end
