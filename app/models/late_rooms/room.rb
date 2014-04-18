module LateRooms
  class Room

    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def self.from_hotel_response(xml_response)
      xml_response.xpath('hotel_rooms/room').map {|room| new room}
    end

    def room_id
      @room_id ||= value('ref')
    end

    def description
      @description ||= value('type_description') + " " + bed_type
    end

    def bed_type
      @bed_type ||= value('bed_type') == "Both" ? "Double or Twin" : value('bed_type')
    end

    def rooms_available
      @rooms_available ||= value('rooms_available').to_i
    end

    def rooms_available?
      rooms_available > 0
    end

    def breakfast?
      value('breakfast')
    end

    def dinner?
      value('dinner')
    end

    def sleeps
      @sleeps ||= value('sleeps').to_i
    end

    def price      
      @price ||= total_price ? total_price / total_nights : nil
    end

    def total_nights
      xml.xpath('rate').count
    end

    def cancellation_days
      @cancellation_days ||= value('cancellation_days').to_i
    end

    def cancellation?
      cancellation_days === 0
    end


    def total_price
      total = 0.0
      xml.xpath('rate/numeric_price').each do |price|
        night_price = price.text.to_f
        total += night_price > 0 ? night_price : 0
      end
      total
    end

    # def to_json
    #   return nil unless total_price
    #   {
    #     provider: :laterooms,
    #     description: description,
    #     price: price,
    #     total_price: total_price,
    #     id: room_id,
    #     breakfast: breakfast?,
    #     dinner: dinner?,
    #     cancellation: cancellation?
    #   }
    # end

    def commonize(search_criteria, link = nil)
      return nil unless total_price
      {
        provider: :laterooms,
        description: description,
        price: price,
        total_price: total_price,
        link: link,
        id: room_id,
        breakfast: breakfast?,
        dinner: dinner?,
        cancellation: cancellation?
      }
    end


    def value(path)
      el = xml.at_xpath(path)
      el.text if el
    end

  end

end
