module Expedia
  class HotelList < Expedia::Response

    attr_reader :hotels

    def initialize(hotels)
      @hotels = hotels
    end

    def self.from_responses(expedia_responses)
      hotels = expedia_responses.flat_map do |response| 
        if response.exception?
          Log.error "Expedia exception: #{response}"
          nil
        else
          Expedia::HotelListResponse.new(response).hotels
        end
      end
      new hotels.compact
    end

    def page_hotels(&block)
      yield hotels
    end

  end

end
