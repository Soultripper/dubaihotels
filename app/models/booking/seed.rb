module Booking::Seed
  class << self

    def cities(offset=0, rows=1000)
      cities = Booking::Client.cities show_timezone: 1, offset: offset, rows: rows
      return nil if cities.empty?
      cities.map {|city| City.from_booking city}
    end

    def regions(offset=0, rows=1000)
      regions = Booking::Client.regions offset: offset, rows: rows
      return nil if regions.empty? 
      regions.map {|region| Region.from_booking region}
    end

    def countries(offset=0, rows=1000)
      countries = Booking::Client.countries offset: offset, rows: rows
      return nil if countries.empty?
      countries.map  {|country| Country.from_booking country}
    end

    def hotels(offset=0, rows=1000)
      hotels = Booking::Client.hotels offset: offset, rows: rows
      return nil if hotels.empty?
      hotels.map  {|hotel| BookingHotel.from_booking hotel}
    end

    def region_hotels(offset=0, rows=1000)
      region_hotels = Booking::Client.region_hotels offset: offset, rows: rows
      return nil if region_hotels.empty? 
      region_hotels.map  {|region_hotel| RegionBookingHotelLookup.from_booking region_hotel}
    end

    def hotel_images(offset=0, rows=1000)
      hotel_images = Booking::Client.hotel_images offset: offset, rows: rows
      return nil if hotel_images.empty? 
      hotel_images.map  {|hotel_image| BookingHotelImage.from_booking hotel_image}
    end

    def hotel_facility_types
      facility_types = Booking::Client.hotel_facility_types languagecodes: 'en'
      facility_types.map {|facility_type| BookingHotelFacilityType.from_booking facility_type}
    end

  end
end