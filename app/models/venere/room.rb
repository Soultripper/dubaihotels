module Venere
  class Room

    attr_reader :xml, :hotel_id

    def initialize(xml, hotel_id)
      @xml, @hotel_id = xml, hotel_id
    end

    def self.from_hotel_response(xml_response, hotel_id)
      xml_response.xpath('AvailStays/AvailStay').map {|room_xml| new room_xml, hotel_id}
    end

    def available_rooms
      @available_rooms ||= xml.xpath('AvailRooms/AvailRoom')
    end

    def available_room
      available_rooms[0]
    end

    def id
      @room_id ||= room_value('@roomID').to_i
    end

    def description
      @description ||= room_value('@roomName')
    end


    def breakfast?
      @breakfast ||= room_value('@breakfastIncluded').to_bool
    end

    def sleeps
      @sleeps ||= room_value('@standardOccupancy').to_i
    end

    def price      
      @price ||=  value('PriceInfo/@displayPrice').to_f
    end

    def commonize(search_criteria)
      return nil unless price > 0
      {
        provider: :venere,
        description: description,
        price: price,
        link: "http://www.venere.com/hotel/?htid=#{hotel_id}&lg=en&ref=#{Venere::Client.AFFID}"
      }
    end

    def room_value(path)
      el = available_room.xpath(path)
      el.text if el
    end

    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

  end

end
