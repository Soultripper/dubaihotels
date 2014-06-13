class Providers::Booking::HotelAmenity < Providers::Base
  attr_accessible :booking_facility_type_id, :booking_hotel_id, :facility_type_id, :value


  def self.fetch_missing
    hotel_facility_ids = Amenity.matched_ids.join(',')

    Hotel.without_amenities.find_in_batches(batch_size: 30) do |hotels|
      booking_hotel_ids =  hotels.map(&:id).join(',')
      results = Booking::Client.hotel_facilities hotel_ids: booking_hotel_ids, hotelfacilitytype_ids: hotel_facility_ids
      hotel_amenities = results.map {|json| from_booking json}
      import hotel_amenities, :validate => false
    end
  end

  def self.fetch(hotel_ids)
    hotel_facility_ids = Amenity.matched_ids.join(',')

    hotel_ids.each_slice(30) do |booking_hotel_ids|
      results = Booking::Client.hotel_facilities hotel_ids: booking_hotel_ids.join(','), hotelfacilitytype_ids: hotel_facility_ids
      hotel_amenities = results.map {|json| from_booking json}
      where(booking_hotel_id: booking_hotel_ids).delete_all
      import hotel_amenities, :validate => false
    end
  end

  def self.from_booking(json)
    new  booking_hotel_id:      json['hotel_id'],
      booking_facility_type_id: json['hotelfacilitytype_id'],
      facility_type_id:         json['facilitytype_id'],
      value:                    json['value']
  end
end
