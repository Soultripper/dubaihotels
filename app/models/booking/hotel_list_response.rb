module Booking
  class HotelListResponse 

    attr_reader :name, :data, :page_no

    def initialize(data, page_no=0)
      @data, @page_no = data, page_no
    end

    def more_pages?
      is_chunked? and page_no < total_pages
    end

    def total_pages
      data['chunks']
    end

    def is_chunked?
      !data.is_a?(Array)
    end

    def results
      is_chunked? ? data['result'] : data
    end

    def hotels
      @hotels ||= results.map {|response| Booking::HotelResponse.new response}
    end

    def hotel_ids
      data.map {|h| h['hotel_id'] }
    end

    def page_hotels(&block)
      total = hotels.count
      Log.debug "Processing #{total} Booking hotels"
      yield self.hotels if block_given?      
      return unless more_pages?
      # response = self
      # Booking::
      #   response = Expedia::HotelListResponse.new(response.next_page)
      #   Log.debug "Processing aditional #{response.hotels.count} Expedia hotels"
      #   total += response.hotels.count
      #   yield response.hotels if block_given?
      # end 
      # nil
    end


  end

end
