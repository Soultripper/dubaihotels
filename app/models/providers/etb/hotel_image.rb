class Providers::Etb::HotelImage < Providers::Base
  attr_accessible :etb_hotel_id, :image, :room_id, :size

  belongs_to :etb_hotel
  def self.cols
    "etb_hotel_id, room_id, size, image"   
  end    
end
