module Booking
  class HotelListResponse 

    attr_reader :name, :data

    def initialize(data)
      @data = data
    end

    def hotels
      data.map {|response| Booking::HotelResponse.new response}
      # Hotel.where('booking_hotel_id in (?)', hotel_ids)
    end

    def hotel_ids
      data.map {|h| h['hotel_id'] }
    end

    def hotels_summary
      data['HotelList']['HotelSummary']
    end

    def hotel_list?
      hotels_summary.is_a?(Array) 
    end

  end

end
