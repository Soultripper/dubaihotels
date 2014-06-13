class Providers::Splendia::Hotel < Providers::Base
  attr_accessible :big_image, :category, :category_id, :city, :city_id, :club, :country, :currency, :description, :facilities, :hotel_currency, :latitude, :longitude, :name, :offers, :original_price, :other_services, :postal_code, :price, :product_id, :product_name, :product_url, :rating, :reviews, :small_image, :stars, :stars_rating, :state_province_code, :state_province_name, :street


  def self.cols
    "id, name, country, city, city_id, state_province_name, state_province_code, street, postal_code, stars, club, product_url, facilities, description, latitude, longitude, hotel_currency, category_id, price, original_price, product_name, product_id, currency, stars_rating, small_image, big_image, other_services, reviews, rating, category, offers"
  end

end
