class Providers::Booking::Hotel < Providers::Base

  self.primary_key = "id"
  acts_as_mappable  :lat_column_name => :latitude,
                    :lng_column_name => :longitude

  attr_accessible :district,:nr_rooms,:city,:check_in_to,:check_in_from,:minrate,:url,
                  :review_nr,:address,:commission,:ranking,:city_id,:review_score,:longitude,:latitude,:max_rooms_in_reservation,
                  :max_persons_in_reservation,:name,:hoteltype_id,:preferred,:country_code,:class_is_estimated,:is_closed,
                  :check_out_to,:check_out_from,:zip,:contractchain_id,:classification,:maxrate,:languagecode,:currencycode, :id,
                  :process_state


  has_many :booking_hotel_images, :foreign_key => 'booking_hotel_id'

  def self.from_booking(json, process_state = 0)
    new  id: json['hotel_id'],
      district: json['district'],
      nr_rooms: json['nr_rooms'],
      city: json['city'],
      check_in_to: json['checkin']['to'],
      check_in_from: json['checkin']['from'],
      minrate: json['minrate'],
      url: json['url'],
      review_nr: json['review_nr'],
      address: json['address'],
      commission: json['commission'],
      ranking: json['ranking'],
      city_id: json['city_id'],
      review_score: json['review_score'],
      longitude: json['location']['longitude'],
      latitude: json['location']['latitude'], 
      max_rooms_in_reservation: json['max_rooms_in_reservation'],
      max_persons_in_reservation: json['max_persons_in_reservation'],
      name: json['name'],       
      preferred: json['preferred'],
      country_code: json['countrycode'],
      hoteltype_id: json['hoteltype_id'],
      class_is_estimated: json['class_is_estimated'] ? true : false,
      is_closed: json['is_closed'] ? false : true,
      check_out_to: json['checkout']['to'],
      check_out_from: json['checkout']['from'],
      zip: json['zip'],
      contractchain_id: json['contractchain_id'],
      classification: json['class'],
      maxrate: json['maxrate'],     
      languagecode: json['languagecode'],       
      currencycode: json['currencycode'], 
      process_state: process_state
  end                  

  def self.seed_from_booking(offset=0, rows=1000)
    delete_all if offset == 0
    while booking_hotels = Booking::Seed.hotels(offset, rows)
      import booking_hotels, :validate => false
      offset += rows
    end
  end

  def self.fetch(hotel_ids)
    hotel_ids.each_slice(500) do |ids|
      hotels_json = Booking::Client.hotels hotel_ids: ids.join(',')
      booking_hotels = hotels_json.map  {|hotel| from_booking hotel, 3}
      where(id: ids).delete_all
      import booking_hotels, :validate => false
    end
  end

  # def self.without_hotel_images
  #   Hotel.booking_only.
  #       joins('LEFT JOIN hotel_images on hotel_images.hotel_id = hotels.id').
  #       where('hotel_images.id IS NULL').
  #       select('booking_hotel_id').
  #       pluck(:booking_hotel_id)
  # end

  def self.without_booking_hotel_images
      joins('LEFT JOIN providers.booking_hotel_images on booking_hotel_images.booking_hotel_id = booking_hotels.id').
      where('booking_hotel_images.* IS NULL').
      select('booking_hotels.id')
  end

  def self.without_descriptions
      joins('LEFT JOIN providers.booking_hotel_descriptions d on d.booking_hotel_id = booking_hotels.id').
      where('d.booking_hotel_id IS NULL').
      select('booking_hotels.id')
  end

  def self.without_amenities
    joins('LEFT JOIN providers.booking_hotel_amenities a on a.booking_hotel_id = booking_hotels.id').
    where('a.* IS NULL').
    select('booking_hotels.id')
  end

end
