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

    def self.search_in_parallel(ids, search_criteria, options={})
      new(ids, search_criteria).search(options)
    end

    def search(options={})
      create_response Booking::Client.post_hotel_availability(params(options))
    end

    # Assume client has already made first page call to retreive page size, so add 1 to page_no
    def search_in_parallel(options={})
      responses, search_params = [], params(options)

      (conn = Booking::Client.http).in_parallel do 
        ids.each_slice((options[:slice] || DEFAULT_SLICE)) do |sliced_ids|
          Log.info "Requesting #{sliced_ids.count} hotels from booking.com"
          responses << conn.post( Booking::Client.url + '/bookings.getHotelAvailability', search_params.merge(hotel_params(sliced_ids)))
        end
      end
      create_response concat_responses(responses)
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
