class BookingHotelDescription < ActiveRecord::Base
  attr_accessible :booking_hotel_id, :description, :description_type_id

  def self.fetch_missing
    without_booking_hotel_descriptions.find_in_batches(batch_size: 500) do |hotels|
      booking_hotel_ids =  hotels.map(&:booking_hotel_id).join(',')
      descriptions = Booking::Client.hotel_descriptions hotel_ids: booking_hotel_ids, descriptiontype_ids: 6, languagecodes: 'en'
      hotel_descriptions = descriptions.map {|json| BookingHotelDescription.from_booking json}
      import hotel_descriptions.compact, :validate => false
    end
  end

  def self.fetch(hotel_ids)
    hotel_ids.each_slice(500) do |booking_hotel_ids|
      descriptions = Booking::Client.hotel_descriptions hotel_ids: booking_hotel_ids.join(','), descriptiontype_ids: 6, languagecodes: 'en'
      hotel_descriptions = descriptions.map {|json| BookingHotelDescription.from_booking json}
      BookingHotelDescription.where(booking_hotel_id: booking_hotel_ids).delete_all
      import hotel_descriptions.compact, :validate => false
    end
  end


  def self.from_booking(json)
    return unless json['languagecode']=='en'
    BookingHotelDescription.new  booking_hotel_id:           json['hotel_id'],
      description:         json['description'],
      description_type_id: json['descriptiontype_id']
  end

  def self.without_booking_hotel_descriptions
    Hotel.booking_only.where('hotels.description is null').
    joins('LEFT JOIN booking_hotel_descriptions on booking_hotel_descriptions.booking_hotel_id = hotels.booking_hotel_id').
    where('booking_hotel_descriptions.id IS NULL').
    select('hotels.id, hotels.booking_hotel_id')
  end

end
