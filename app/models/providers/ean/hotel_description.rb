class Providers::Ean::HotelDescription < Providers::Base
  attr_accessible :ean_hotel_id, :description, :language_code

  def self.cols
    "ean_hotel_id, language_code, description"   
  end  

end
