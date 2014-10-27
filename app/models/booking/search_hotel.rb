module Booking
  class SearchHotel < Booking::Search

    INIT_BATCH_SIZE = 10

    attr_reader :ids

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

    def self.for_availability(ids, search_criteria, options={})
      ids = *ids 
      return nil if ids.empty?
      new(ids, search_criteria).availability(options)
    end

    def search(options={})
      create_response Booking::Client.get_hotel_availability(params(options))
    end

    def availability(options={})
      create_response Booking::Client.get_block_availability(params(options))
    end

    # Assume client has already made first page call to retreive page size, so add 1 to page_no
    # def page_hotels(options={}, &block)
    #   responses, search_params = [], params(options)

    #   time = Benchmark.realtime do 
    #     (conn = Booking::Client.http).in_parallel do 
    #       ids.each_slice((options[:slice] || DEFAULT_SLICE)) do |sliced_ids|
    #         Log.info "Requesting #{sliced_ids.count} hotels from booking.com"
    #         # responses << conn.post( Booking::Client.url + '/bookings.getHotelAvailability', search_params.merge(hotel_params(sliced_ids)))
    #         responses << conn.post( Booking::Client.url + '/bookings.getBlockAvailability', search_params.merge(hotel_params(sliced_ids)))
    #       end
    #     end
    #   end

    #   hotels = collect_hotels(responses, 1)
    #   Log.info "Collected #{hotels.count} hotels out of #{responses.count} Booking responses for comparison in #{time}s"
    #   yield hotels if block_given?
    # end 

    # def collect_hotels(responses, page_start = 0)
    #   list_responses = responses.map.with_index do |r,idx| 
    #     begin
    #       Booking::HotelListResponse.new(JSON.parse(r.body), idx)
    #     rescue Exception => msg
    #       Log.error "Booking error response: #{r}, #{msg}"
    #       nil  
    #     end
    #   end

    #   list_responses.flat_map(&:hotels) if list_responses
    # end

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

    def page_hotels(options={}, &block)
      requests, search_params = [], params(options)

      HydraConnection.in_parallel do
        requests << request(ids.take(INIT_BATCH_SIZE), &block) 
        ids.drop(INIT_BATCH_SIZE).each_slice((options[:slice] || DEFAULT_SLICE)) { |hotel_ids| requests << request(hotel_ids, &block) }
        requests
      end
    end

    def request(hotel_ids=nil, &success_block)
      #req =  HydraConnection.post Booking::Client.url + '/bookings.getBlockAvailability', :body=> search_params.merge(hotel_params(hotel_ids))
      req =  HydraConnection.post Booking::Client.url + '/bookings.getHotelAvailability', :body=> search_params.merge(hotel_params(hotel_ids))
      req.on_complete do |response|
        Log.debug "Booking.com response complete: uri=#{response.request.url}, time=#{response.total_time}sec, code=#{response.response_code}, message=#{response.return_message}"

        if response.success?
          #Log.debug response.body
         begin
            hotels_list = Booking::HotelListResponse.new(JSON.parse(response.body), 1)
          rescue Exception => msg
            Log.error "Booking error response: #{response.body}, #{msg}"
            nil  
          end
          if hotels_list and hotels_list.hotels.count > 0
            Log.debug "Booking: Found #{hotels_list.hotels.count} hotels out of #{(hotel_ids || ids).count}"
            block_given? ? (yield hotels_list.hotels) : hotels_list
          else
            nil
          end         
        elsif response.timed_out?
          Log.error ("BOOKING.com request timed out")
        elsif response.code == 0
          Log.error(response.return_message)
        else
          Log.error("Booking.com HTTP request failed: #{response.code}, body=#{response.request.url}")
        end
      end
      req
    end

     def fetch_hotels(hotel_ids=nil)
      request(hotel_ids).run.handled_response
    end

  end
end
