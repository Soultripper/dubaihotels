class RoomsCache
  include CacheHandler

  attr_reader :cache_key, :hotels, :search_criteria


  def initialize(cache_key)
    @hotels, @cache_key = [], cache_key + "_rooms"
  end

  def self.update(hotel_comparisons, cache_key, search_criteria)
    rooms_cache = find_or_create_from_cache(cache_key).update(hotel_comparisons, search_criteria)
  end

  def hotel_ids
    hotels.map &:id
  end

  def update(hotels_to_add, cur_search_criteria)
    @search_criteria = cur_search_criteria
    add_hotels hotels_to_add
    collect_missing_ids
    load_missing_rooms
    persist
  end

  def add_hotels(hotels_to_add)    
    hotels_to_add.each { |h| hotels << h unless hotel_ids.include?(h.id) }
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
    time = Benchmark.realtime{
      threads = []
      threads << threaded(:booking) {  Booking::SearchHotel.for_availability(@provider_ids[:booking], search_criteria) }
      threads << threaded(:expedia) {  Expedia::SearchHotel.search(@provider_ids[:expedia], search_criteria) }        
      threads << threaded(:venere)  {  Venere::SearchHotel.search(@provider_ids[:venere], search_criteria) }      
      Log.debug "Waiting for rooms threads to finish"
      threads.each &:join
    }
    Log.info "------ ROOMS COMPLETED IN #{time} seconds -------- "
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
    return unless provider_hotels
    Log.debug "Comparing rooms for #{provider_hotels.count} hotels for #{provider_key}"
    HotelComparer.compare(hotels, provider_hotels, provider_key) do |comparable_hotel, provider_hotel|

      common_provider_hotel = provider_hotel.commonize(search_criteria)
      common_provider_hotel[:rooms_loaded] = true
      comparable_hotel.add_provider_deal(common_provider_hotel)

      # if provider_key==:booking_hotel_id
      #   common_provider_hotel[:link] = search_criteria.booking_link(comparable_hotel)
      #   set_rooms_link(common_provider_hotel)
      # elsif provider_key==:laterooms_hotel_id and common_provider_hotel
      #   common_provider_hotel[:link] = search_criteria.laterooms_link(comparable_hotel)
      #   set_rooms_link(common_provider_hotel)
      # end
    end
  end


end