module Splendia
  class HotelResponse

    attr_reader :xml, :index

    def initialize(xml, index=0)
      @xml, @index = xml, index
    end

    def self.from_list_response(xml_response)
      xml_response.xpath('//hotel').map.with_index {|hotel, index| new hotel, index}
    end

    def self.from_response(xml_response)
      new xml_response.at_xpath('//Hotelinfo')
    end

    def fetch_hotel
      @hotel ||= Hotel.find_by_splendia_hotel_id hotel_id
    end

    def hotel
      @hotel ||= SplendiaHotel.find hotel_id
    end

    def id
      @id ||= value('hotelid').to_i
    end

    def hotel_id
      id
    end

    def ranking
      index
    end

    def min_price
      cheapest_room.daily_price
    end

    def max_price
      expensive_room.daily_price
    end

    def rooms
      @rooms ||= Splendia::Room.from_hotel_response xml
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

    def commonize(search_criteria)
      {
        provider: :splendia,
        provider_id: hotel_id,
        room_count: rooms_count,
        min_price: min_price.to_f,
        max_price: max_price.to_f,        
        ranking: ranking,
        rooms: rooms.map{|r| r.commonize(search_criteria)},
        #link: link
      }
    rescue Exception => msg  
      Log.error "Splendia Hotel #{id} failed to convert: #{msg}"
      nil
    end

    def link
      value('trackingurl')
    end

    def avg_price(price, nights)
      price / nights
    end
    
    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

  end

end
