class Providers::Etb::Hotel < Providers::Base
  attr_accessible :address, :address_city, :check_in, :check_out, :city_id, :credit_cards, :email, :hotel_number_reviews, :hotel_review_score, :hotel_type, :latitude, :longitude, :min_price, :name, :phone, :picture, :stars, :total_rooms, :url, :zipcode

  has_many :images,     :class_name => "EtbHotelImage"
  # has_many :properties, :class_name => "EanHotelAttributeLink"

  def self.cols    
    "id, name, address, zipcode, city_id, stars, check_in, check_out, picture, total_rooms, longitude, latitude, hotel_review_score, hotel_number_reviews, credit_cards, phone, url, email, hotel_type, address_city, min_price"
  end

  def fetch_hotel
    @hotel||=Hotel.find_by_etb_hotel_id id
  end


  

end
