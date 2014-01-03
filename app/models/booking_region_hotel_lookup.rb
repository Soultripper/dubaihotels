class BookingRegionHotelLookup < ActiveRecord::Base
  attr_accessible :booking_hotel_id, :region_id

  def self.from_booking(json)
    BookingRegionHotelLookup.new region_id: json['region_id'], booking_hotel_id: json['hotel_id']
  end

  def self.seed_from_booking(offset, rows=1000)
    delete_all if offset == 0
    while region_booking_hotels = Booking::Seed.region_hotels(offset)
      import region_booking_hotels, :validate => false
      offset += rows
    end
  end    
end
