module EasyToBook
  class HotelResponse

    attr_reader :xml, :index

    def initialize(xml, index)
      @xml, @index = xml, index
    end

    def self.from_response(xml_response)
      xml_response.xpath('//Hotel').map.with_index {|hotel, index| new hotel, index}
    end

    def fetch_hotel
      @hotel ||= Hotel.find_by_etb_hotel_id hotel_id
    end

    def hotel
      @hotel ||= ETBHotel.find hotel_id
    end

    def id
      @id ||= value('Id').to_i
    end

    def hotel_id
      id
    end

    def ranking
      index
    end

    def min_price
      cheapest_room.price
    end

    def max_price
      expensive_room.price
    end

    def rooms
      @rooms ||= EasyToBook::Room.from_hotel_response xml
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
      {
        provider: :easy_to_book,
        provider_hotel_id: hotel_id,
        room_count: rooms_count,
        min_price: avg_price(min_price, search_criteria.total_nights),
        max_price: avg_price(max_price, search_criteria.total_nights),        
        ranking: ranking,
        rooms: nil,
        # link: create_aff_link(location, search_criteria)
      }
    rescue
      Log.error "EasyToBook Hotel #{id} failed to convert"
      nil
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
