module LateRooms
  class HotelResponse

    attr_reader :xml, :index

    def initialize(xml, index=0)
      @xml, @index = xml, index
    end

    def self.from_list_response(xml_response)
      xml_response.xpath('//hotel').map.with_index {|hotel, index| new hotel, index}
    end

    def self.from_response(xml_response)
      new xml_response.at_xpath('//hotel')
    end

    def fetch_hotel
      @hotel ||= Hotel.find_by_laterooms_hotel_id hotel_id
    end

    def hotel
      @hotel ||= LateRoomsHotel.find hotel_id
    end

    def id
      @id ||= value('hotel_ref').to_i
    end

    def hotel_id
      id
    end

    def ranking
      0
    end

    def min_price
      cheapest_room.price
    end

    def max_price
      expensive_room.price
    end

    def rooms
      @rooms ||= LateRooms::Room.from_hotel_response(xml).sort_by(&:total_price).select {|room| room.total_price > 0 }
    end

    def rooms_count
      rooms.count
    end

    def cheapest_room
      rooms[0]
    end

    def expensive_room
      rooms[-1]
    end

    def commonize(search_criteria, location)
      return unless rooms and rooms.length > 0
      {
        provider: :laterooms,
        provider_hotel_id: hotel_id,
        room_count: rooms_count,
        min_price: min_price,
        max_price: max_price,        
        ranking: ranking,
        rooms: nil,
      }
    rescue Exception => msg  
      Log.error "LateRooms Hotel #{id} failed to convert: #{msg}"
      nil
    end
    
    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

  end

end
