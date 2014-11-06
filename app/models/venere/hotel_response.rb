module Venere
  class HotelResponse

    attr_reader :xml, :index

    def initialize(xml, index=0)
      @xml, @index = xml, index
    end

    def self.from_list_response(xml_response)
      xml_response.xpath('//AvailResult').map.with_index {|hotel, index| new hotel, index}
    end

    def self.from_response(xml_response)
      new xml_response.at_xpath('//AvailResult')
    end

    def hotel
      @hotel ||= VenereHotel.find hotel_id
    end

    def id
      @id ||= value('@propertyID').to_i
    end

    def hotel_id
      id
    end

    def min_price
      cheapest_room.price if cheapest_room
    end

    def max_price
      expensive_room.price if expensive_room
    end

    def rooms
      @rooms ||= remove_duplicate_rooms(Venere::Room.from_hotel_response(xml, id).sort_by(&:price))
    end

    def remove_duplicate_rooms(rooms)
      temp_rooms = []
      rooms.each do |room|
        temp_rooms << room unless temp_rooms.find {|temp_room| temp_room.id == room.id} 
      end
      temp_rooms
    end

    def cheapest_room
      rooms[0]
    end

    def expensive_room
      rooms[-1]
    end

    # def commonize(search_criteria)
    #   return unless rooms and rooms.length > 0 and min_price.to_f > 0 and max_price.to_f > 0
    #   {
    #     provider: :venere,
    #     provider_id: hotel_id,
    #     room_count: rooms_count,
    #     min_price: min_price.to_f / search_criteria.total_nights,
    #     max_price: max_price.to_f / search_criteria.total_nights,        
    #     rooms: rooms.map {|room| room.commonize(search_criteria)},
    #   }
    # rescue Exception => msg  
    #   Log.error "Venere Hotel #{id} failed to convert: #{msg}"
    #   nil
    # end

    def avg_price(price, nights)
      price.to_f / nights
    end
    
    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

    def rooms_available?
      rooms and rooms.length > 0 and min_price.to_f > 0 and max_price.to_f > 0
    end


    def provider
      :venere
    end

    def provider_id
      hotel_id
    end
    
    def rooms_count
      rooms.count
    end

    def avg_min_price(search_criteria)  
      avg_price(min_price,search_criteria.total_nights)   
    end

    def avg_max_price(search_criteria)
      avg_price(max_price,search_criteria.total_nights)   
    end


  end

end
