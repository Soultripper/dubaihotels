class BookingHotel < ActiveRecord::Base
  acts_as_mappable  :lat_column_name => :latitude,
                    :lng_column_name => :longitude

  attr_accessible :district,:nr_rooms,:city,:check_in_to,:check_in_from,:minrate,:url,
                  :review_nr,:address,:commission,:ranking,:city_id,:review_score,:longitude,:latitude,:max_rooms_in_reservation,
                  :max_persons_in_reservation,:name,:hoteltype_id,:preferred,:country_code,:class_is_estimated,:is_closed,
                  :check_out_to,:check_out_from,:zip,:contractchain_id,:classification,:maxrate,:languagecode,:currencycode, :id

  def self.from_booking(json)
    BookingHotel.new  id: json['hotel_id'],
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
      class_is_estimated: json['class_is_estimated'],
      is_closed: json['is_closed'] ? false : true,
      check_out_to: json['checkout']['to'],
      check_out_from: json['checkout']['from'],
      zip: json['zip'],
      contractchain_id: json['contractchain_id'],
      classification: json['class'],
      maxrate: json['maxrate'],     
      languagecode: json['languagecode'],       
      currencycode: json['currencycode']
  end                  

  def self.seed_from_booking(offset=0, rows=1000)
    delete_all if offset == 0
    while booking_hotels = Booking::Seed.hotels(offset, rows)
      import booking_hotels, :validate => false
      offset += rows
    end
  end
end
