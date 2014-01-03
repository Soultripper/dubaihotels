module Splendia
  class Room

    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def self.from_hotel_response(xml_response)
      xml_response.xpath('rooms/room').map {|room| new room}
    end

    def description
      @description ||= value('roomname')
    end

    def price      
      @price ||= value('fullratewithtaxes').to_f
    end

    def commonize(search_criteria, link)
      {
        provider: :splendia,
        description: description,
        price: avg_price(search_criteria.total_nights),
        link: link
      }
    end


    def avg_price(nights)
      price / nights
    end

    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

  end

end
