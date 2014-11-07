module Booking
  class SearchHotel < Booking::Search

    def self.for_availability(ids, search_criteria, options={})
      ids = *ids 
      return nil if ids.empty?
      new(search_criteria, ids).for_availability(options)
    end

    def for_availability(options={})
      create_response Booking::Client.get_block_availability(params(options))
    end

    def params(options={})
      search_params.merge(hotel_params).merge(options)
    end

    def hotel_params(custom_ids=nil)
      {
        order_by: :popularity,
        hotel_ids: (custom_ids || ids).join(','),
        limit_incremental_prices: 1,
        include_internet: 1,
        include_addon_type: 1
      }
    end

    def request(hotel_ids=nil, options={}, &success_block)
      request_type = options[:norooms] ? '/bookings.getHotelAvailability' : '/bookings.getBlockAvailability'
      HydraConnection.post Booking::Client.url + request_type, body: search_params.merge(hotel_params(hotel_ids))
    end

    def slice_size; 40; end
    def first_slice_size; 10; end

  end
end
