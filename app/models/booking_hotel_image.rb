class BookingHotelImage < ActiveRecord::Base
  attr_accessible :booking_hotel_id, :description_type_id, :photo_id, :url_max_300, :url_original, :url_square60


  def self.from_booking(json)
    BookingHotelImage.new booking_hotel_id: json['hotel_id'],
      description_type_id: json['descriptiontype_id'],
      photo_id: json['photo_id'],
      url_max_300: json['url_max300'],
      url_original: json['url_original'],
      url_square60: json['url_square60']
  end               

  def self.seed_from_booking(offset=0, rows=1000)
    delete_all if offset == 0
    while booking_hotel_images = Booking::Seed.hotel_images(offset, rows)
      import booking_hotel_images, :validate => false
      offset += rows
    end
  end

end
