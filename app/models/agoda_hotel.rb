class AgodaHotel < ActiveRecord::Base
  attr_accessible :addressline1, :addressline2, :brand_id, :brand_name, :chain_id, :chain_name, :checkin, :checkout, :city, :city_id, :continent_id, :continent_name, :country, :country_id, :countryisocode, :hotel_formerly_name, :hotel_id, :hotel_name, :hotel_translated_name, :latitude, :longitude, :number_of_reviews, :numberfloors, :numberrooms, :overview, :photo1, :photo2, :photo3, :photo4, :photo5, :rates_currency, :rates_from, :rating_average, :star_rating, :state, :url, :yearopened, :yearrenovated, :zipcode



  def hotel_id
    self.id
  end

  def self.cols
    "id,chain_id,chain_name,brand_id,brand_name,hotel_name,hotel_formerly_name,hotel_translated_name,addressline1,addressline2,zipcode,city,state,country,countryisocode,star_rating,longitude,latitude,url,checkin,checkout,numberrooms,numberfloors,yearopened,yearrenovated,photo1,photo2,photo3,photo4,photo5,overview,rates_from,continent_id,continent_name,city_id,country_id,number_of_reviews,rating_average,rates_currency"
  end

  def fetch_hotel
    @hotel||=Hotel.find_by_ean_hotel_id id
  end
end
