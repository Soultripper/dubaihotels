class RoomsCache
  include CacheHandler

  attr_reader :hotels, :search_cache_key, :search_criteria


  def initialize(current_cache_key)
    @hotels, @search_cache_key, = [], current_cache_key 
  end

  def cache_key
    search_cache_key + "_rooms"
  end

  def self.update(hotel_ids, cache_key)


    rooms_cache = find_or_create_from_cache(cache_key).update(hotel_ids)
  end

  def find_hotel(slug)
    hotels.find {|hotel| hotel.slug == slug}
  end

  def current_hotel_ids
    hotels.map &:id
  end

  def not_found(ids_to_find)
    current_set = current_hotel_ids.to_set
    search_set = ids_to_find.to_set
    (search_set - current_set).to_a
  end

  def cached_search_hotels(not_found_hotel_ids)
    cached_search = HotelSearch.find search_cache_key
    @search_criteria = cached_search.search_criteria
    cached_search.hotels.select {|h| not_found_hotel_ids.include?(h.id)}
  end

  def update(new_hotel_ids)
    return unless add_new_hotels new_hotel_ids
    collect_missing_ids
    load_missing_rooms
    persist
  end

  def add_new_hotels(new_hotel_ids) 
    not_found_hotel_ids = not_found(new_hotel_ids)
    return nil unless not_found_hotel_ids.length > 0
    missing_hotels = cached_search_hotels(not_found_hotel_ids)
    hotels.concat(missing_hotels) 
    persist 
    Log.debug "Added and persisted #{missing_hotels.count} missing hotels from rooms search"
  end

  def collect_missing_ids
    @provider_ids = {}
    HotelsConfig::PROVIDER_IDS.each {|provider, provider_key| @provider_ids[provider] = []}
    hotels.each do |hotel_comparison|
      HotelsConfig::PROVIDER_IDS.each do |provider, provider_key|
        unless hotel_comparison.has_rooms_for_provider?(provider) and hotel_comparison[provider_key]
          @provider_ids[provider] << hotel_comparison[provider_key]
          @provider_ids[provider].compact!
        end
      end
    end
    @provider_ids    
  end


  def load_missing_rooms
    Log.info "------ ROOMS SEARCH STARTED (#{cache_key}) -------- "

    time = Benchmark.realtime{
      threads = []
      threads << threaded(:booking) {  Booking::SearchHotel.for_availability(@provider_ids[:booking], search_criteria) }
      # threads << threaded(:expedia) {  Expedia::SearchHotel.search(@provider_ids[:expedia], search_criteria) }        
      # threads << threaded(:venere)  {  Venere::SearchHotel.search(@provider_ids[:venere], search_criteria) }      
      Log.debug "Rooms_Cache: Waiting for rooms threads to finish"
      threads.each &:join
    }
    Log.info "------ ROOMS COMPLETED IN #{time} seconds --------"
  end

  def threaded(provider, &block)
    thread = Thread.new do 
      hotel_list_response = yield
      add_rooms_to_hotels(hotel_list_response.hotels, HotelsConfig::PROVIDER_IDS[provider]) if hotel_list_response
      ActiveRecord::Base.connection.close
    end
    thread
  end

  def add_rooms_to_hotels(provider_hotels, provider_key)
    return unless provider_hotels and provider_hotels.count > 0 
    Log.debug "Rooms_Cache: Comparing #{provider_hotels.count} hotels for #{provider_key.upcase}"
    HotelComparer.compare(hotels, provider_hotels, provider_key) do |comparable_hotel, provider_hotel|

      common_provider_hotel = provider_hotel.commonize(search_criteria)
      common_provider_hotel[:rooms_loaded] = true

      # if provider_key==:booking_hotel_id
      #   common_provider_hotel[:link] = search_criteria.booking_link(comparable_hotel)
      #   # set_rooms_link(common_provider_hotel)
      # # elsif provider_key==:laterooms_hotel_id and common_provider_hotel
      # #   common_provider_hotel[:link] = search_criteria.laterooms_link(comparable_hotel)
      # #   set_rooms_link(common_provider_hotel)
      # end

      comparable_hotel.add_provider_deal(common_provider_hotel)
    end
  end


end