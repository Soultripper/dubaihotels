class BookingHotelFacilityType < ActiveRecord::Base
  attr_accessible :facility_type_id, :language_code, :name, :value_type, :flag, :id


  def self.from_booking(json)
    BookingHotelFacilityType.new id:     json['hotelfacilitytype_id'],
      facility_type_id:       json['facilitytype_id'], 
      language_code:          json['languagecode'], 
      name:                   json['name'], 
      value_type:             json['type'] 
  end

  def self.seed_from_booking
    booking_facility_types = Booking::Seed.hotel_facility_types
    import booking_facility_types, :validate => false
  end  

  def self.matched_ids
    where('flag is not null').pluck(:id)
  end
end
