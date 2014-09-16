class HotelRoomWorker
  include Sidekiq::Worker
  extend Forwardable
  
  sidekiq_options retry: false

  attr_accessor :search, :hotels, :finished

  def perform(hotel_ids, cache_key)

    # using_worker(hotel_ids, cache_key)
    using_rooms_cache(hotel_ids, cache_key)
  end

  def using_rooms_cache(hotel_ids, cache_key)
    RoomsCache.update hotel_ids, cache_key
  end

  # def using_worker(hotel_ids, cache_key)

  #   @search = HotelSearch.find cache_key
  #   @hotels = @search.hotels.select {|h| hotel_ids.include?(h.id) and h.booking_hotel_id}
  #   request_booking_rooms    
  #   @search.persist

  # end


  # def find_rooms(hotel_ids, cache_key)

  #   @search = HotelSearch.find cache_key
  #   rooms_cache = RoomsCache.find_or_create_from_cache cache_key
  #   hotel_ids_to_process = @rooms_cache.not_found(hotel_ids)
  #   @hotels = @search.hotels.select {|h| h.booking_hotel_id and hotel_ids_to_process.include?(h.id)}
  #   rooms_cache.update(hotels)
  # end

  # def search_criteria
  #   search.search_criteria
  # end

  # def booking_hotel_ids
  #   @booking_hotel_ids ||= hotels.map do |hotel|
  #     hotel.booking_hotel_id unless hotel.has_rooms_for_provider? :booking
  #   end.compact
  # end

  # def request_booking_rooms    
  #   return if booking_hotel_ids.empty?

  #   hotel_list_response = Booking::SearchHotel.for_availability(booking_hotel_ids, search_criteria)

  #   return unless hotel_list_response.hotels.length > 0

  #   time = Benchmark.realtime{
  #     Log.info "Retrieving Booking.com room information for #{booking_hotel_ids.count} hotels"
  #     hotel_list_response.hotels.each do |hotel|
  #       cached_hotel = hotels.find {|h| h.booking_hotel_id == hotel.id}
  #       provider_deal = cached_hotel.find_provider_deal(:booking)
  #       common_provider_hotel = hotel.commonize(search_criteria)
  #       common_provider_hotel[:link] = search_criteria.booking_link(cached_hotel)
  #       cached_hotel.compare_and_add common_provider_hotel
  #     end
  #   }
  #   Log.info "------ ROOM SEARCH COMPLETED IN #{time} seconds -------- "

  # end

  # def find_booking_hotels(ids)
  # end


  # def start(provider, &block)
  #   rooms = nil
  #   time = Benchmark.realtime { rooms = yield }
  #   rooms.select! {|r| r[:price].to_f >  0}
  #   Log.info "Realtime availabilty check for #{provider}, finding #{rooms.count} rooms, took #{time}s" 
  #   return unless rooms.count > 0
  #   @search.add_rooms(rooms)
  #   notify
  # rescue => msg
  #   Log.error "Unable to retrieve rooms for provider #{provider}. #{msg}"    
  # end

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