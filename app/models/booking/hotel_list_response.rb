module Booking
  class HotelListResponse 

    attr_reader :name, :data

    def initialize(data)
      @data = data
    end

    def hotels
      @hotels ||= data.map {|response| Booking::HotelResponse.new response}
    end

    def hotel_ids
      data.map {|h| h['hotel_id'] }
    end


  end

end
