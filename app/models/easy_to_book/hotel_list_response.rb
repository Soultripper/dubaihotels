module EasyToBook
  class HotelListResponse 

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def hotels
      @hotels ||= EasyToBook::HotelResponse.from_list_response(data).sort_by(&:ranking).reverse
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
