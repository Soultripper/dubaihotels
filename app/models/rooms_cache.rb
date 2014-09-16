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

  def update(new_hotel_ids)
    return unless add_new_hotels new_hotel_ids
    collect_missing_ids
    load_missing_rooms
    persist
  end

  def hash_hotels(found_hotels)
    @hash_hotels = HotelsHash.by_location(location) 
  end

  def add_new_hotels(new_hotel_ids) 
    not_found_hotel_ids = not_found(new_hotel_ids)
    Log.debug "#{not_found_hotel_ids.count}"
    return nil unless not_found_hotel_ids.length > 0
    missing_hotels = cached_search_hotels(not_found_hotel_ids)
    hotels.concat(missing_hotels) 
    persist 
    Log.debug "Added and persisted #{missing_hotels.count} missing hotels from rooms search"
  end

  def not_found(ids_to_find)
    current_set = current_hotel_ids.to_set
    search_set = ids_to_find.to_set
    (search_set - current_set).to_a
  end

  def find_hotel(slug)
    hotels.find {|hotel| hotel.slug == slug}
  end

  def find_hotel_by(provider, id)
    hotels.find do |hotel|
      !hotel.provider_deals.find {|deal| deal[:provider] == provider.to_sym && deal[:provider_id] == id.to_i}.nil?
    end
  end

  def current_hotel_ids
    hotels.map &:id
  end

  def cached_search_hotels(not_found_hotel_ids)
    @search_criteria = cached_search.search_criteria
    cached_search.hotels.select {|h| not_found_hotel_ids.include?(h.id)}
  end

  def cached_search
    _cached_search ||= HotelSearch.find search_cache_key
  end



  def collect_missing_ids
    @provider_ids = {}
    HotelsConfig.provider_keys.each {|provider| @provider_ids[provider] = []}
    hotels.each do |hotel_comparison|
      HotelsConfig.provider_keys.each do |provider|
        provider_deal = hotel_comparison.find_provider_deal provider                              
        unless provider_deal[:rooms]
          @provider_ids[provider] << provider_deal[:provider_id]
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
      add_rooms_to_hotels(hotel_list_response.hotels, provider) if hotel_list_response
      ActiveRecord::Base.connection.close
    end
    thread
  end

  def add_rooms_to_hotels(provider_hotels_found, provider)
    return unless provider_hotels_found and provider_hotels_found.count > 0 
    Log.debug "Rooms_Cache: Comparing #{provider_hotels_found.count} hotels for #{provider.upcase}"
    provider_hotels_found.each do |provider_hotel|
      hotel = find_hotel_by provider, provider_hotel.id
      common_provider_hotel = provider_hotel.commonize(search_criteria)
      common_provider_hotel[:rooms_loaded] = true
      hotel.add_provider_deal(common_provider_hotel)
    end  

  end


end