class HotelsHotelAmenity < ActiveRecord::Base
  belongs_to :hotel
  belongs_to :hotel_amenity
  # attr_accessible :title, :body
end
