require 'csv'

class Reporter

  def self.hotels_by_location(location)
    hotels = Hotel.by_location location
    CSV.generate(force_quotes:true) {|csv| hotels.each {|hotel| csv << [hotel.name, hotel.star_rating, "http://www.hot5.com/#{hotel.slug}"]}}
  end
end