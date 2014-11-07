module LateRooms
  class HotelListResponse 

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def hotels
      @hotels ||= LateRooms::HotelResponse.from_list_response(data)
    end

    def hotel_ids
      hotels.map {|h| h['hotel_id'] }
    end

    def page_hotels(&block)
      total = hotels.count
      yield self.hotels if block_given?      
    end

  end

end
