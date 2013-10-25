module Booking
  class HotelResponse
    include Mongoid::Document
    include Mongoid::Timestamps

    field :_id, type: Integer, default: ->{ self.hotel_id}


    def hotel_id
      self['hotel_id']
    end

    def total
      
    end

    def min_price
      self['min_price']
    end

    def max_price
      self['max_price']
    end

    def currency
      self['currency_code']
    end

    def rooms
    end

    def rooms_count
      self['available_rooms']
    end


    def commonize
      {
        provider: :booking,
        provider_hotel_id: id,
        room_count: rooms_count,
        min_price: min_price,
        max_price: max_price,
        rooms: nil
      }
    rescue
      Log.error "Booking Hotel #{id} failed to convert"
      nil
    end


  end

end
