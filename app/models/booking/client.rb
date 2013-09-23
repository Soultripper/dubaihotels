require 'nokogiri'
require 'open-uri'
class Booking::Client 

  class << self 
  # attr_accessible :title, :body

    def url
       "http://www.booking.com"
    end

    def hotels_in(city_name, page_no=1, rows=20)
      offset = (page_no-1) * rows
      city = City.where(name: city_name).first     
      request("/searchresults.en-gb.html?city=#{city.booking_id}&rows=#{rows}&offset=#{offset}") do |doc|
        doc.css('.hotel_name_link').map {|f| f.content} 
      end
    end

    def request(query, &block)
      doc = Nokogiri::HTML(open("#{url}#{query}"))
      yield doc if block_given?
    end
  end
end
