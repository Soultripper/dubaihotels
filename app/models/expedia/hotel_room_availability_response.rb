module Expedia
  class HotelRoomAvailabilityResponse < Expedia::Response

    attr_reader :name, :data

    def initialize(data)
      super 'HotelRoomAvailabilityResponse', data
    end

    def rooms
      return [] if error?
      if rooms_summary?
        rooms_summary.map {|room| Expedia::Room.new(room)}
      else
        [Expedia::Room.new(rooms_summary)]
      end
    end

    def error?
      data['EanWsError']
    end

    def rooms_summary
      data['HotelRoomResponse']
    end

    def rooms_summary?
      rooms_summary.is_a?(Array) 
    end

  end

end
