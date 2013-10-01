class HotelImage < ActiveRecord::Base
  attr_accessible :byte_size, :caption, :default_image, :ean_hotel_id, :height, :thumbnail_url, :url, :width

  # belongs_to :hotel, :primary_key => :ean_hotel_id

  def self.cols
    "ean_hotel_id, caption, url, width, height, byte_size, thumbnail_url, default_image"   
  end  

  def ean_hotel
    @ean_hotel ||= Hotel.find_by_ean_hotel_id self.ean_hotel_id
  end
end
