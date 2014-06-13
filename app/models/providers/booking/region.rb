class Providers::Booking::Region < Providers::Base
  attr_accessible :region_id, :country_code, :name, :region_type, :language_code

  def self.from_booking(json)
    BookingRegion.new region_id:     json['region_id'],
      country_code:           json['countrycode'], 
      language_code:          json['languagecode'], 
      name:                   json['name'], 
      region_type:            json['region_type'] 
  end

  def self.seed_from_booking(offset, rows=1000)
    delete_all if offset == 0
    while booking_regions = Booking::Seed.regions(offset)
      import booking_regions, :validate => false
      offset += rows
    end
  end  
end
