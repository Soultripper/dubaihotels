module Agoda
  class Room

    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def self.from_hotel_response(xml_response)
      xml_response.xpath('Room').map {|room| new room}
    end

    def room_id
      @price ||= value('@id').to_i 
    end


    def description
      @description ||= value('@name')
    end

    def price      
      @price ||= value('@inc').to_f
    end

    def wifi?
      value('@freewifi')
    end

    def cancellation?
      value('@freecancellation')
    end

    def pay_later?
      value('@booknowpaylater')
    end

    def commonize(search_criteria)
      {
        provider: :agoda,
        description: description,
        price: avg_price(search_criteria.total_nights),
        #link: link,
        wifi: wifi?,
        cancellation: cancellation?,
        pay_later: pay_later?
      }
    end
    
    def link
      value('@url')
    end


    def avg_price(nights)
      price
    end

    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

  end

end
