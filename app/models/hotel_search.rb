class HotelSearch
  extend Forwardable
  attr_reader :location, :search_criteria, :results_counter, :started

  def_delegators :@results_counter, :reset, :page_inc, :finished?, :finish, :include?

  PROVIDERS = [:booking, :expedia]
  def initialize(location, search_criteria, use_cache=true)
    @use_cache = use_cache
    @results_counter = ResultsCounter.new PROVIDERS
    @location, @search_criteria = location, search_criteria
  end

  def self.find_or_create(location, search_criteria)
    HotelSearch.new(location, search_criteria).find_or_create   
  end

  def find_or_create
    return self unless @use_cache
    Rails.cache.fetch cache_key, expires_in: 1.minute do 
      Log.info "Starting new search: #{cache_key}"
      self
    end       
  end

  def start
    return self if @started
    @started = true
    all_hotels
    Log.debug "Hotel Search: #{total_hotels} hotels to search"
    persist
    search_by_destination
    self
  end


  def all_hotels
    @all_hotels ||= Hotel.by_location(location).limit(500).to_a 
  end


  def results
    results = {
      total: total_hotels,
      location: location,
      search_criteria: search_criteria,
      started: @started,
      finished: finished?
    }
    cur_hotels = compared_hotels
    cur_hotels = cur_hotels.length > 0 ? cur_hotels : all_hotels
    HotelSearchPageResult.new cur_hotels.clone, results
  end

  def hotels
    @hotels ||= compared_hotels
  end

  def compared_hotels
    all_hotels.select {|h| !h.provider_deals.empty?}
  end

  def total_hotels
    all_hotels.count
  end

  def search_by_destination    
    threads = []
    threads << threaded {request_booking_hotels} if include? :booking
    threads << threaded {request_expedia_hotels} if include? :expedia
    Log.debug "Waiting for threads to finish"
    # @threads.each &:join
  end

  def threaded(&block)
    # return yield
    thread = Thread.new do 
      yield
      ActiveRecord::Base.connection.close
    end
    thread
  end

  def request_expedia_hotels
    provider, key = :expedia, :ean_hotel_id
    reset provider
    hotel_ids = ids_for key    
    time = Benchmark.realtime do 
      Expedia::Search.by_location(location, search_criteria).page_hotels do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
    Log.info "Realtime comparison of #{provider} for location: #{location.city}, #{location.country} took #{time}s" 
    finish_and_persist provider
  end

  def request_booking_hotels
    provider, key = :booking, :booking_hotel_id
    reset provider
    hotel_ids = ids_for key    
    time = Benchmark.realtime do       
      Booking::SearchCity.page_hotels(location.city_id, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
    Log.info "Realtime comparison of #{provider} for location: #{location.city}, #{location.country} took #{time}s"    
    finish_and_persist provider 
  end

  # def request_expedia_hotels    
  #   provider, key = :expedia, :ean_hotel_id
  #   reset provider
  #   response = Expedia::Search.by_location(location, search_criteria)
  #   response.page_hotels do |expedia_hotels|
  #     page_inc provider
  #     add_new_expedia_hotels expedia_hotels
  #     compare expedia_hotels, key
  #    persist
  #   end

  #   finish :expedia
  # end


  # def add_new_expedia_hotels(expedia_hotels)
  #   hotel_ids_set = Set.new(expedia_hotels.map(&:id))
  #   matched_hotels = Set.new(ids_for(:ean_hotel_id))
  #   unmatached_hotel_ids = hotel_ids_set.difference(matched_hotels)
  #   all_hotels.concat  Hotel.where(ean_hotel_id: unmatached_hotel_ids.to_a).to_a  
  # end


  def finish_and_persist(provider)
    finish provider
    persist
    Log.debug "COMPLETE - #{provider.upcase}: #{hotels.count} hotels compared"
    hotels.count
  end


  def ids_for(provider_key)
    ids_for = all_hotels.map(&provider_key).compact
    Log.debug "Retrieved #{ids_for.count} #{provider_key} hotels for processing"
    ids_for
  end

  def compare_and_persist(hotels, key)
    matches = 0
    # Log.debug "#{hotels.count} hotels found, #{all_hotels.count} all hotels found"
    time = Benchmark.realtime do 
      HotelComparer.compare(all_hotels, hotels, key) do |hotel, provider_hotel|
        matches += 1
        add_to_list(hotel, provider_hotel)
      end    
    end
    persist
    puts "Matched, persisted and compared #{matches} matches out of #{all_hotels.count} hotels in #{time}s"
  end

  def add_to_list(hotel, provider_hotel)
    hotel.compare_and_add(provider_hotel, search_criteria)
    hotel.distance_from_location = hotel.distance_from(@location) unless hotel.distance_from_location
  end

  def persist
    Rails.cache.write(cache_key, self) if @use_cache
  end

  def cache_key
    search_criteria.as_json.merge({query:location.slug})
  end


end