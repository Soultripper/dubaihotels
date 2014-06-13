class Providers::Ean::RoomType < Providers::Base
  attr_accessible :description, :ean_hotel_id, :image, :language_code, :name, :room_type_id

  def self.cols
    "ean_hotel_id, room_type_id, language_code, image, name, description"   
  end  

  def ean_hotel
    @ean_hotel ||= EanHotel.find_by_ean_hotel_id self.ean_hotel_id
  end
end
