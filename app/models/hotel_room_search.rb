class HotelRoomSearch
  extend Forwardable

  attr_reader :hotel, :search_criteria, :results_counter, :started

  def_delegators :hotel, :ean_hotel_id, :booking_hotel_id

  attr_accessor :total_hotels

  def initialize(hotel, search_criteria)
    @hotel, @search_criteria = hotel, search_criteria
  end

  def self.check_availability(hotel, search_criteria)
    new(hotel, search_criteria).check_availability
  end

  def check_availability
    @rooms, @threads = [], []
    threaded {request_expedia_hotels}
    threaded {request_booking_hotels}
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

  def request_expedia_hotels
    return unless ean_hotel_id
    expedia_response = Expedia::Search.check_room_availability(ean_hotel_id, search_criteria)
    return unless expedia_response
    Log.debug expedia_response
    @rooms.concat(expedia_response.rooms.map do |room|
      room.commonize(search_criteria)
    end)
  end

  def request_booking_hotels
    return unless booking_hotel_id
    booking_hotel = Booking::Search.by_hotel_ids([booking_hotel_id], search_criteria).hotels
    return unless booking_hotel.length > 0
    @rooms.concat(booking_hotel.first.rooms.map do |room|
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

  def results_counter
    @results_counter ||={
      expedia:{pages: 0, finished: false},
      booking:{pages: 0, finished: false}
    }
  end

end