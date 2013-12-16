module Booking
  class SearchLocation < Booking::Search

    attr_reader :location

    def initialize(location, search_criteria)
       super search_criteria
        @location = location
    end

    def self.search(location, search_criteria, options={})
      new(location, search_criteria).search(options)
    end

    def self.page_hotels(location, search_criteria, options={}, &block)
      new(location, search_criteria).page_hotels(options, &block)
    end

    def search(options={}) 
      create_response Booking::Client.get_hotel_availability(params(options)), options[:chunk]
    end

    # Assume client has already made first page call to retreive page size, so add 1 to page_no
    def page_hotels(options={}, &block)  
      responses, search_params, total_pages  = [], params(options), 1

      time = Benchmark.realtime do 
        first_search_response = search(options.merge({chunk: 1}))

        yield first_search_response.hotels if block_given?
        return unless first_search_response.more_pages? 

        # we already have the first page 
        total_pages = first_search_response.total_pages
        Log.info "Found #{total_pages} pages for location #{location} from booking.com"

        (conn = Booking::Client.http).in_parallel do 
          (total_pages - 1).times do |page_no|
            page_no = page_no+2
            Log.info "Requesting chunk #{page_no} for location #{location} from booking.com"          
            responses << conn.post( Booking::Client.url + '/bookings.getHotelAvailability', search_params.merge({chunk: page_no}))
          end
        end
      end

      Log.info "Received #{total_pages} chunk responses from booking.com in #{time}s"

      hotels = collect_hotels(concat_responses(responses, 2))
      Log.info "Collected #{hotels.count} hotels out of #{total_pages} booking.com responses for comparison"
      yield hotels if block_given?
    end

    def params(options={})
      search_params.merge(location_params).merge(options)
    end

    def location_params
      {
        latitude: location.latitude, 
        longitude: location.longitude, 
        radius: 20}
    end


  end
end
