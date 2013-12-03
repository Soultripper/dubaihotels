module EasyToBook
  class Room

    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def self.from_hotel_response(xml_response)
      xml_response.xpath('Roomtype').map {|room| new room}
    end

    def description
      @description ||= value('Roomname')
    end

    def price(currency_code)
      other_currency = value("Price/Gross/@#{currency_code}")
      @price ||= (other_currency ? other_currency :  value('Price/Gross')).to_f
    end

    def commonize(search_criteria)
      {
        provider: :easy_to_book,
        description: description,
        price: avg_price(price(search_criteria.currency_code), search_criteria.total_nights),
        link: link
      }
    end
    
    def link
      value('Hoteldetailslink')
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
