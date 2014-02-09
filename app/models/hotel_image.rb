class HotelImage < ActiveRecord::Base
  attr_accessible :byte_size, :caption, :default_image, :ean_hotel_id, :height, :thumbnail_url, :url, :width

  belongs_to :hotel

  def self.cols
    "hotel_id, caption, url, width, height, byte_size, thumbnail_url, default_image"   
  end  

  # def ean_hotel
  #   @ean_hotel ||= EanHotel.find_by_ean_hotel_id self.ean_hotel_id
  # end


  def self.populate_booking_hotel_images
    hotel_ids = Hotel.booking_only.without_images.select(:booking_hotel_id).pluck(:booking_hotel_id)

    hotels =  Hotel.booking_only.
                  joins(:booking_hotel_images).
                  where('booking_hotel_id IN ?', ids).
                  select("hotels.id, 
                    'BookingHotel' as caption, 
                    booking_hotel_images.url_max_300 as url, 
                    booking_hotel_images.url_square60 as thumbnail_url,  
                    CASE description_type_id WHEN 1 THEN FALSE ELSE TRUE END as default_image")
  end

end
