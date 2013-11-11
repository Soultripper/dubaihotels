module Expedia
  class HotelListResponse < Expedia::Response

    attr_reader :name, :data

    def initialize(data)
      super 'HotelListResponse', data
    end

    def page_hotels(&block)

      Log.debug "Processing #{hotels.count} Expedia hotels"
      yield self.hotels   

      response = self

      while response.more_pages?
        response = Expedia::HotelListResponse.new(response.next_page)
        Log.debug "Processing #{hotels.count} Expedia hotels"
        yield response.hotels
      end   

    end

    def hotels
      @hotels ||= if hotel_list?
        hotels_summary.map {|hotel| Expedia::HotelResponse.new(hotel)}
      else
        Expedia::HotelResponse.new(hotels_summary)
      end
    end
 
    def hotel_ids_set
      Set.new(hotels.map(&:id))
    end

    def hotels_summary
      data['HotelList']['HotelSummary']
    end

    def hotel_list?
      hotels_summary.is_a?(Array) 
    end

  end

end
