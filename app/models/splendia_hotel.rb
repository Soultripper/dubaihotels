class SplendiaHotel < ActiveRecord::Base
  attr_accessible :big_image, :category, :category_id, :city, :city_id, :club, :country, :currency, :description, :facilities, :hotel_currency, :latitude, :longitude, :name, :offers, :original_price, :other_services, :postal_code, :price, :product_id, :product_name, :product_url, :rating, :reviews, :small_image, :stars, :stars_rating, :state_province_code, :state_province_name, :street
end
