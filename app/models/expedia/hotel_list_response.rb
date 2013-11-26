module Expedia
  class HotelListResponse < Expedia::Response

    attr_reader :name, :data

    def initialize(data)
      super 'HotelListResponse', data
    end


    def page_hotels(&block)
      total = hotels.count
      Log.debug "Processing #{total} Expedia hotels"
      yield self.hotels if block_given?
      response = self
      while response.more_pages?
        response = Expedia::HotelListResponse.new(response.next_page)
        Log.debug "Processing additional #{response.hotels.count} Expedia hotels"
        total += response.hotels.count
        yield response.hotels if block_given?
      end 
      nil
    end

    def collect_hotels
      new_hotels = self.hotels 
      response = self
      time = Benchmark.realtime do
        while response.more_pages?
          response = Expedia::HotelListResponse.new(response.next_page)
          Log.debug "Collected an additional #{response.hotels.count} Expedia hotels"
          new_hotels.concat response.hotels
        end   
      end
      Log.debug "Collected #{new_hotels.count} Expedia hotels in #{time}s"
      new_hotels
    end

    def hotels
      @hotels ||= if hotel_list?
        hotels_summary.map {|hotel| Expedia::HotelResponse.new(hotel)}
      else
        [Expedia::HotelResponse.new(hotels_summary)]
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

    def is_error?
    end
  end

end
