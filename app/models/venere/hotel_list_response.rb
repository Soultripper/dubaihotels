module Venere
  class HotelListResponse 

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def hotels
      @hotels ||= Venere::HotelResponse.from_list_response(data)
    end

    def hotel_ids
      hotels.map &:id
    end

    def page_hotels(&block)
      total = hotels.count
      yield self.hotels if block_given?      
    end

  end

end
