class RoomWorker
  include Sidekiq::Worker
  extend Forwardable
  
  sidekiq_options retry: false

  attr_accessor :search, :hotel, :finished, :provider_ids


  def perform(hotel_id, cache_key)
    @hotel = Hotel.with_providers.find hotel_id
    @search =  Rails.cache.read cache_key
    @finished = false

    unless hotel and search
      Log.warn "Unable to find hotel and search to perform availabilty search for hotel #{hotel_id}, cache key #{cache_key} "
      return
    end

    @provider_ids = hotel.provider_ids

    time = Benchmark.realtime{
      threads = []
      threads << threaded {request_booking_rooms}       if booking_hotel_id
      threads << threaded {request_expedia_rooms}       if ean_hotel_id
      threads << threaded {request_easy_to_book_rooms}  if etb_hotel_id
      threads << threaded {request_agoda_rooms}         if agoda_hotel_id
      threads << threaded {request_splendia_rooms}      if splendia_hotel_id
      threads << threaded {request_laterooms_rooms}     if laterooms_hotel_id
      threads << threaded {request_venere_rooms}        if venere_hotel_id

      Log.debug "Waiting for room worker threads to finish"
      threads.each &:join
    }
    Log.info "------ ROOM SEARCH COMPLETED IN #{time} seconds -------- "
    @search.finish
    notify
  end

  def booking_hotel_id
    provider_ids[:booking]
  end

  def ean_hotel_id
    provider_ids[:expedia]
  end

  def etb_hotel_id
    provider_ids[:easy_to_book]
  end

  def agoda_hotel_id
    provider_ids[:agoda]
  end

  def splendia_hotel_id
    provider_ids[:splendia]
  end

  def laterooms_hotel_id
    provider_ids[:laterooms]
  end


  def venere_hotel_id
    provider_ids[:venere]
  end

  def threaded(&block)
    thread = Thread.new do 
      yield
      ActiveRecord::Base.connection.close
    end
    thread
  end

  def find_provider_id_for(provider)

  end
  def request_expedia_rooms
    start :expedia do 
      room_availability_response = Expedia::Search.check_room_availability(ean_hotel_id, search_criteria)
      return unless room_availability_response
      room_availability_response.rooms.map { |room| room.commonize(search_criteria) }.compact
      # expedia_rooms.concat(room_availability_response.rooms.map { |room| room.commonize_to_hotels_dot_com(search_criteria, ean_hotel_id) })
    end
  end

  def request_booking_rooms
    start :booking do 
      hotel_list_response = Booking::SearchHotel.for_availability(booking_hotel_id, search_criteria)
      return unless hotel_list_response.hotels.length > 0# and booking_hotel = hotel.booking_hotel
      hotel_response = hotel_list_response.hotels.first
      hotel_response.rooms.map do |room|
        room.link = search_criteria.booking_link(hotel)
        room.commonize(search_criteria)
      end
    end
  end

  def request_easy_to_book_rooms
    start :easy_to_book do 
      hotels_list_response = EasyToBook::SearchHotel.for_availability(etb_hotel_id, search_criteria)
      return unless hotels_list_response.hotels.length > 0
      hotels_list_response.hotels.first.rooms.map do |room|
        room.commonize(search_criteria)
      end
    end
  end

  def request_agoda_rooms
    start :agoda do 
      hotels_list_response = Agoda::SearchHotel.for_availability(agoda_hotel_id, search_criteria)
      return unless hotels_list_response.hotels.length > 0
      hotels_list_response.hotels.first.rooms.map do |room|
        room.commonize(search_criteria)
      end
    end
  end

  def request_splendia_rooms
    start :splendia do 
      hotels_list_response = Splendia::SearchHotel.for_availability(splendia_hotel_id, search_criteria)
      return unless hotels_list_response.hotels.length > 0
      hotel_response = hotels_list_response.hotels.first
      hotel_response.rooms.map do |room|
        room.commonize(search_criteria,  hotel_response.link)
      end
    end
  end

  def request_laterooms_rooms
    start :laterooms do 
      hotels_list_response = LateRooms::SearchHotel.for_availability(laterooms_hotel_id, search_criteria)
      return unless hotels_list_response.hotels.length > 0
      hotel_response = hotels_list_response.hotels.first
      hotel_response.rooms.map do |room|
        link = search_criteria.laterooms_link(hotel)
        room.commonize(search_criteria, link)
      end
    end
  end  

  def request_venere_rooms
    start :venere do 
      hotels_list_response = Venere::SearchHotel.for_availability(venere_hotel_id, search_criteria)
      return unless hotels_list_response.hotels.length > 0
      hotel_response = hotels_list_response.hotels.first
      hotel_response.rooms.map do |room|
        room.commonize(search_criteria)
      end
    end
  end

  def start(provider, &block)
    rooms = nil
    time = Benchmark.realtime { rooms = yield }
    rooms.select! {|r| r[:price].to_f >  0}
    Log.info "realtimeltime availabilty check for #{provider}, finding #{rooms.count} rooms, took #{time}s" 
    return unless rooms.count > 0
    @search.add_rooms(rooms)
    notify
  # rescue => msg
  #   Log.error "Unable to retrieve rooms for provider #{provider}. #{msg}"    
  end

  def search_criteria
    @search.search_criteria
  end

  def channel
    @search.channel
  end

  def notify
    Log.debug "Notifying channel #{channel} of hotel rooms update. Current rooms = #{@search.rooms_results.count}"
    Pusher[channel].trigger_async('availability_update', { key: @search.cache_key}) 
  end


end