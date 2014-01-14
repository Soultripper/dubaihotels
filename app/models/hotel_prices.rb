class HotelPrices
  
  attr_reader :hotel_id, :stars, :geo_location, :user_rating, :ranking

  PROVIDER_IDS = %W[booking_hotel_id ean_hotel_id splendia_hotel_id etb_hotel_id laterooms_hotel_id agoda_hotel_id]

  def initialize(hotel_details)
    @hotel_id     = hotel_details[:id]
    @stars        = hotel_details[:star_rating].to_f
    @geo_location = hotel_details[:geog]
    @user_rating  = hotel_details[:user_rating].to_f
    @ranking      = hotel_details[:ranking].to_f  
  end

  def hotel
    @hotel ||= Hotel.find hotel_id
  end

  def self.by_location(location, proximity_in_metres = 20000)
    Hotel.by_location(location).select('id, star_rating, geog, user_rating, ranking,' + PROVIDER_IDS.join(',')).map {|hotel| new hotel}
  end
end