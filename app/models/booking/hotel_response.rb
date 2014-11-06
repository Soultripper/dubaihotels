module Booking
  class HotelResponse
    include Mongoid::Document

    field :_id, type: Integer, default: ->{ self.hotel_id}

    # def hotel
    #   @hotel ||= Hotel.find_by_booking_hotel_id hotel_id
    # end



    def hotel_id
      self['hotel_id']
    end

    def price_in_currency
      other_currency[0]
    end

    def other_currency
      self['other_currency']
    end

    def other_currency?
      other_currency
    end

    def min_price
      return rooms[0].total if block_response? and rooms[0]
      other_currency? ? price_in_currency['min_price'] : self['min_price']
    end

    def max_price
      return rooms[-1].total if block_response? and rooms[-1]
      other_currency? ? price_in_currency['max_price'] : self['max_price']
    end

    def local_min_price
      self['min_total_price']
    end

    def local_max_price
      self['max_total_price']
    end

    def currency
      self['currency_code']
    end

    def block_response?
      blocks
    end

    def blocks
      self[:block]
    end

    def rooms
      return [] unless block_response?
      @rooms ||= blocks.
        map {|block| Booking::Room.new block}.
        sort_by {|room| room.total}
    end



    def cheapest_room
      rooms[0]
    end

    def expensive_room
      rooms[-1]
    end

 
    # def commonize(search_criteria)
    #   {
    #     provider: :booking,
    #     provider_id: id,
    #     room_count: rooms.count,
    #     min_price: avg_price(min_price, search_criteria.total_nights),
    #     max_price: avg_price(max_price, search_criteria.total_nights),
    #     rooms: rooms.map {|room| room.commonize(search_criteria)}
    #   }
    # rescue => msg
    #   Log.error "Booking Hotel #{id} failed to convert: #{msg}"
    #   nil
    # end

     def provider
      :booking
    end

    def provider_id
      id
    end

    def rooms_count
      return self['available_rooms'] unless block_response?
      rooms.count
      #self['available_rooms']
    end
    
    def avg_min_price(search_criteria)  
      avg_price(min_price, search_criteria.total_nights)
    end

    def avg_max_price(search_criteria)
      avg_price(max_price, search_criteria.total_nights)
    end

    def avg_price(price, nights)
      block_response? ? (price.to_f / nights) : price.to_f
    end
    
  end

end
