class HotelRoomSearch
  extend Forwardable

  attr_reader :hotel, :search_criteria, :started

  def_delegators :hotel, :ean_hotel_id, :booking_hotel_id, :etb_hotel_id

  attr_accessor :total_hotels

  def initialize(hotel, search_criteria)
    @hotel, @search_criteria = hotel, search_criteria
  end

  def self.check_availability(hotel, search_criteria)
    new(hotel, search_criteria).check_availability
  end

  def check_availability
    @rooms, @threads = [], []
    threaded {request_expedia_rooms}
    threaded {request_booking_rooms}
    threaded {request_easy_to_book_rooms}
    @threads.each &:join
    self
  end

  def results
    @rooms.sort_by {|r| r[:price].to_f}
  end

  def threaded(&block)
    @threads << Thread.new do 
      yield; ActiveRecord::Base.connection.close
    end
  end

  def request_expedia_rooms
    return unless ean_hotel_id
    room_availability_response = Expedia::Search.check_room_availability(ean_hotel_id, search_criteria)
    return unless room_availability_response
    @rooms.concat(room_availability_response.rooms.map do |room|
      room.commonize(search_criteria)
    end)
  end

  def request_booking_rooms
    return unless booking_hotel_id
    booking_hotel = Booking::SearchHotel.for_availability(booking_hotel_id, search_criteria)
    return unless booking_hotel.hotels.length > 0
    @rooms.concat(booking_hotel.hotels.first.rooms.map do |room|
      room.commonize(search_criteria)
    end)
  end

  def request_easy_to_book_rooms
    return unless etb_hotel_id
    hotels_list_response = EasyToBook::SearchHotel.for_availability(etb_hotel_id, search_criteria)
    return unless hotels_list_response.hotels.length > 0
    @rooms.concat(hotels_list_response.hotels.first.rooms.map do |room|
      room.commonize(search_criteria)
    end)
  end

  def add_to_list(hotel, provider_hotel)
    return nil unless hotel
    hotel.compare_and_add provider_hotel 
    return if @hotels.include?(hotel)
    hotel.distance_from_location = hotel.distance_from location
    @hotels << hotel
  end

  def find_or_add(hotel_collection, provider_hotel)
    hotel_collection.find {|hotel| hotel.booking_hotel_id == provider_hotel.id}
  end


end