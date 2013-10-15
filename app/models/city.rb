class City < ActiveRecord::Base
  attr_accessible :id, :country_code, :language_code, :latitude, :longitude, :name, :timezone_name, :timezone_offset

  def from_booking(json)
    City.new  id:           json['city_id'],
      country_code:         json['countrycode'],
      language_code:        json['languagecode'], 
      latitude:             json['latitude'], 
      longitude:            json['longitude'], 
      name:                 json['name'], 
      timezone_name:     if json['timezone'] then json['timezone']['name'] end, 
      timezone_offset:   if json['timezone'] then json['timezone']['offset'] end   
  end

  def self.seed_from_booking
    offset, cities = 0, []

    while booking_cities = Booking::Seed.cities(offset)
      cities += booking_cities
      offset += 1000
    end

    transaction do 
      delete_all
      import cities
    end
  end
end
