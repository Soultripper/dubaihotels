module Booking::Seed
  class << self

    def cities(offset=0)
      cities = Booking::Client.cities show_timezone: 1, offset: offset, rows: 1000
      return nil if cities.empty?
      cities.map {|city| City.from_booking city}
    end

    def countries(offset=0)
      countries = Booking::Client.countries offset: offset, rows: 1000
      return nil if countries.empty?
      countries.map  {|country| Country.from_booking country}
    end

    def hotels(offset=0)
      hotels = Booking::Client.hotels offset: offset, rows: 1000
      return nil if hotels.empty?
      hotels.map  {|hotel| BookingHotel.from_booking hotel}
    end

  end
end