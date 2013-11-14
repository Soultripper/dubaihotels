module Expedia
  class HotelList < Expedia::Response

    attr_reader :hotels

    def initialize(hotels)
      @hotels = hotels
    end

    def self.from_responses(expedia_responses)
      hotels = expedia_responses.flat_map  {|response| Expedia::HotelListResponse.new(response).hotels }
      new hotels.compact
    end

    def page_hotels(&block)
      yield hotels
    end

  end

end
