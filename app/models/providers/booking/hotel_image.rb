class Providers::Booking::HotelImage < Providers::Base
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

  def self.fetch_missing
    ids = BookingHotel.without_booking_hotel_images
    ids.each_slice(50) do |sliced_ids|
      hotel_images = Booking::Client.hotel_images hotel_ids: sliced_ids.join(',')
      booking_hotel_images = hotel_images.map  {|hotel_image| BookingHotelImage.from_booking hotel_image}
      import booking_hotel_images, :validate => false
    end
  end

  def self.fetch(hotel_ids)
    hotel_ids.each_slice(50) do |sliced_ids|
      hotel_images = Booking::Client.hotel_images hotel_ids: sliced_ids
      booking_hotel_images = hotel_images.map  {|hotel_image| BookingHotelImage.from_booking hotel_image}
      BookingHotelImage.where(booking_hotel_id: sliced_ids).delete_all
      import booking_hotel_images, :validate => false
    end
  end


end
