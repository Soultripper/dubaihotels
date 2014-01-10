class LateRoomsHotel < ActiveRecord::Base
  attr_accessible :id, :accommodation_type, :address1, :appeals, :cancellation_days, :cancellation_policy, :cancellation_terms, :check_in_time, :check_out_time, :city, :city_tax_opted_in, :city_tax_type, :city_tax_value, :country, :country_iso, :county, :created_date, :currency_code, :description, :directions, :facilities, :image, :images, :is_city_tax_area, :latest_check_in_time, :latitude, :longitude, :max_price, :name, :no_of_reviews, :postcode, :price_from, :review_url, :score_out_of_6, :star_accreditor, :star_rating, :total_rooms, :url
end
