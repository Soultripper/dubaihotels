module Agoda
  class HotelResponse

    attr_reader :xml, :index



    def initialize(xml, index=0)
      @xml, @index = xml, index
    end

    def self.from_list_response(xml_response)
      xml_response.remove_namespaces!.xpath('//Hotel').map.with_index {|hotel, index| new hotel, index}
    end

    def self.from_response(xml_response)
      new xml_response.at_xpath('//Hotelinfo')
    end

    def hotel
      @hotel ||= AgodaHotel.find hotel_id
    end

    def id
      @id ||= value('@id').to_i
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
      @rooms ||= Agoda::Room.from_hotel_response xml
    end

    def cheapest_room
      rooms[0]
    end

    def expensive_room
      rooms[-1]
    end

    def provider
      :agoda
    end

    def provider_id
      id
    end

    def rooms_count
      rooms.count
    end

    def avg_min_price(search_criteria)  
      min_price
    end

    def avg_max_price(search_criteria)
      max_price
    end



    # def commonize(search_criteria)
    #   {
    #     provider: :agoda,
    #     provider_id: hotel_id,
    #     room_count: rooms_count,
    #     min_price: min_price,
    #     max_price: max_price,        
    #     ranking: ranking,
    #     rooms: rooms.map {|r| r.commonize(search_criteria)},
    #   }
    # rescue Exception => msg  
    #   Log.error "Agoda Hotel #{id} failed to convert: #{msg}"
    #   nil
    # end

    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

  end

end
