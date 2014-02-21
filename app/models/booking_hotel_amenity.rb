class BookingHotelAmenity < ActiveRecord::Base
  attr_accessible :booking_facility_type_id, :booking_hotel_id, :facility_type_id, :value


  def self.fetch_missing
    hotel_facility_ids = BookingHotelFacilityType.matched_ids.join(',')

    without_booking_hotel_amenities.find_in_batches(batch_size: 30) do |hotels|
      booking_hotel_ids =  hotels.map(&:booking_hotel_id).join(',')
      results = Booking::Client.hotel_facilities hotel_ids: booking_hotel_ids, hotelfacilitytype_ids: hotel_facility_ids
      hotel_amenities = results.map {|json| BookingHotelAmenity.from_booking json}
      import hotel_amenities, :validate => false
    end
  end


  def self.from_booking(json)
    BookingHotelAmenity.new  booking_hotel_id:           json['hotel_id'],
      booking_facility_type_id: json['hotelfacilitytype_id'],
      facility_type_id:         json['facilitytype_id'],
      value:                    json['value']
  end

  def self.without_booking_hotel_amenities
    Hotel.booking_only.where('hotels.amenities is null').
    joins('LEFT JOIN booking_hotel_amenities on booking_hotel_amenities.booking_hotel_id = hotels.booking_hotel_id').
    where('booking_hotel_amenities.id IS NULL').
    select('hotels.id, hotels.booking_hotel_id')
  end

end
