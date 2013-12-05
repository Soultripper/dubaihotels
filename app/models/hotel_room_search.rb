class HotelRoomSearch
  extend Forwardable

  attr_reader :hotel_id, :search_criteria, :finished

  def initialize(hotel_id, search_criteria)
    @hotel_id, @search_criteria = hotel_id, search_criteria
  end

  def self.check_availability(hotel_id, search_criteria)
    new(hotel_id, search_criteria, channel).find_or_create
  end

  def self.find_or_create(hotel_id, search_criteria)
    HotelRoomSearch.new(hotel_id, search_criteria).find_or_create   
  end

  def find_or_create
    Rails.cache.fetch cache_key do 
      Log.info "Starting new room search: #{cache_key}"
      self
    end       
  end

  def start
    return self if @started
    @rooms, @finished = [], false
    @started = true
    persist
    check_availability
  end

  def check_availability    
    RoomWorker.perform_async hotel_id, cache_key 
    # RoomWorker.new.perform hotel_id, cache_key 
    self
  end

 def results
    {
      hotel_id: hotel_id,
      rooms: rooms_results,
      finished: @finished
    }
  end

  def rooms_results
    # @rooms.compact! if @rooms
    @rooms.sort_by {|r| r[:price].to_f}
  end

  def persist
    Rails.cache.write(cache_key, self, expires_in: 15.seconds, race_condition_ttl: 5)
  end

  def add_rooms(rooms)
    @rooms.concat(rooms)
    Log.debug "#{rooms.count} found"
    persist
  end

  def cache_key
    search_criteria.as_json.merge({hotel_id: hotel_id})
  end

  def channel
    search_criteria.channel_hotel hotel_id
  end

  def finish
    @finished = true
    persist
  end
   

  # def threaded(&block)
  #   @threads << Thread.new do 
  #     yield; ActiveRecord::Base.connection.close
  #   end
  # end

  # def request_expedia_rooms
  #   return unless ean_hotel_id
  #   room_availability_response = Expedia::Search.check_room_availability(ean_hotel_id, search_criteria)
  #   return unless room_availability_response
  #   @rooms.concat(room_availability_response.rooms.map do |room|
  #     room.commonize(search_criteria)
  #   end)
  # end

  # def request_booking_rooms
  #   return unless booking_hotel_id
  #   hotel_list_response = Booking::SearchHotel.for_availability(booking_hotel_id, search_criteria)
  #   return unless hotel_list_response.hotels.length > 0 and booking_hotel = hotel.booking_hotel
  #   hotel_response = hotel_list_response.hotels.first
  #   @rooms.concat(hotel_response.rooms.map do |room|
  #     room.link = search_criteria.booking_link_detailed(booking_hotel)
  #     room.commonize(search_criteria)
  #   end)
  # end

  # def request_easy_to_book_rooms
  #   return unless etb_hotel_id
  #   hotels_list_response = EasyToBook::SearchHotel.for_availability(etb_hotel_id, search_criteria)
  #   return unless hotels_list_response.hotels.length > 0
  #   @rooms.concat(hotels_list_response.hotels.first.rooms.map do |room|
  #     room.commonize(search_criteria)
  #   end)
  # end

  # def add_to_list(hotel, provider_hotel)
  #   return nil unless hotel
  #   hotel.compare_and_add provider_hotel 
  #   return if @hotels.include?(hotel)
  #   hotel.distance_from_location = hotel.distance_from location
  #   @hotels << hotel
  # end

  # def find_or_add(hotel_collection, provider_hotel)
  #   hotel_collection.find {|hotel| hotel.booking_hotel_id == provider_hotel.id}
  # end


end