class BookingCity < ActiveRecord::Base
  attr_accessible :id, :country_code, :language_code, :latitude, :longitude, :name, :timezone_name, :timezone_offset

  def self.from_booking(json)
    BookingCity.new  id:           json['city_id'],
      country_code:         json['countrycode'],
      language_code:        json['languagecode'], 
      latitude:             json['latitude'], 
      longitude:            json['longitude'], 
      name:                 json['name'], 
      timezone_name:     if json['timezone'] then json['timezone']['name'] end, 
      timezone_offset:   if json['timezone'] then json['timezone']['offset'] end   
  end

  def self.seed_from_booking(offset=0, rows=1000)
    delete_all if offset == 0
    while booking_cities = Booking::Seed.cities(offset, rows)
      import booking_cities, :validate => false
      offset += rows
    end
  end

end
