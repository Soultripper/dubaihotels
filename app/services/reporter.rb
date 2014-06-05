require 'csv'

class Reporter

  attr_reader :csv

  def initialize(csv)
    @csv = csv
  end

  def self.hotels_by_location(location, order)
    hotels = Hotel.by_location(location).reorder order_clause(order)
    headers = %w[name star_rating score ranking user_rating matches url ppc_url]
    CSV.generate(force_quotes:true, write_headers: true, headers: headers) do |csv| 
      hotels.each do |hotel| 
        url = "http://www.hot5.com?hotel=#{hotel.slug}"
        ppc_url = "http://www.hot5.com/?hotel=#{hotel.slug}"
        csv << [hotel.name, hotel.star_rating, hotel.score, hotel.ranking, hotel.user_rating, hotel.matches, url, ppc_url]
      end
    end
  end


  def self.order_clause(order)
    case order.to_sym
      when :score then 'COALESCE(score,0) DESC'
      when :ranking then 'COALESCE(ranking,0) DESC'
      when :name then 'name ASC'
      when :user_rating then 'COALESCE(user_rating,0) DESC'
      when :matches then 'COALESCE(matches,0) DESC'
      else 'COALESCE(star_rating,0) DESC'
    end
  end


end