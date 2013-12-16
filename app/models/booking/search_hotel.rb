module Booking
  class SearchHotel < Booking::Search

    attr_reader :ids

    DEFAULT_SLICE = 600

    def initialize(ids, search_criteria)
       super search_criteria
        @ids = ids
    end

    def self.search(ids, search_criteria, options={})
      new(ids, search_criteria).search(options)
    end

    def self.page_hotels(ids, search_criteria, options={}, &block)
      new(ids, search_criteria).page_hotels(options, &block)
    end

    def self.for_availability(id, search_criteria, options={})
      new([id], search_criteria).availability(options)
    end

    def search(options={})
      create_response Booking::Client.post_hotel_availability(params(options))
    end

    def availability(options={})
      create_response Booking::Client.get_block_availability(params(options))
    end

    # Assume client has already made first page call to retreive page size, so add 1 to page_no
    def page_hotels(options={}, &block)
      responses, search_params = [], params(options)

      (conn = Booking::Client.http).in_parallel do 
        ids.each_slice((options[:slice] || DEFAULT_SLICE)) do |sliced_ids|
          Log.info "Requesting #{sliced_ids.count} hotels from booking.com"
          responses << conn.post( Booking::Client.url + '/bookings.getHotelAvailability', search_params.merge(hotel_params(sliced_ids)))
        end
      end

      concat_responses(responses, 1, &block)
      # Log.info "Collected #{hotels.count} hotels out of #{ids.count} booking.com responses for comparison"
      # yield hotels if block_given?
    end 

    def concat_responses(responses, page_start = 0, &block)
      list_responses = responses.map.with_index {|r,idx| Booking::HotelListResponse.new(JSON.parse(r.body), idx)}
      list_responses.each {|lr| yield lr.hotels}
    end

    def params(options={})
      search_params.merge(hotel_params).merge(options)
    end

    def hotel_params(custom_ids=nil)
      {
        hotel_ids: (custom_ids || ids).join(',')
      }
    end


  end
end
