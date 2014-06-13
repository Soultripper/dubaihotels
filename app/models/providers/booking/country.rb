class Providers::Booking::Country < Providers::Base
  attr_accessible :area, :country_code, :language_code, :name

  def self.all
    @@countries ||= super.to_a
  end

  def self.from_booking(json)
    BookingCountry.new area: json['area'], 
    country_code: json['countrycode'], 
    language_code: json['languagecode'],  
    name: json['name']    
  end

  def self.seed_from_booking
    offset, countries = 0, []

    while booking_countries = Booking::Seed.countries(offset)
      countries += booking_countries
      offset += 1000
    end

    transaction do 
      delete_all
      import countries
    end
  end  

  def self.lookup(code)
    country = all.find {|c| c.country_code == code}
    country ? country.name : ""
  end
end
