class HotelSearch
  attr_reader :location, :search_criteria, :results_counter, :started

  attr_accessor :total_hotels

  def initialize(location, search_criteria)
    @results_counter = ResultsCounter.new [:booking, :expedia]
    @location, @search_criteria = location, search_criteria
  end

  def self.find_or_create(location, search_criteria)
    HotelSearch.new(location, search_criteria).find_or_create   
  end

  def find_or_create
    Rails.cache.fetch cache_key, expires_in: 1.minute do 
      Log.info "Starting new search: #{cache_key}"
      self
    end       
  end

  def start
    return self if @started
    @started = true
    all_hotels
    persist
    search_by_destination
    self
  end

  def results
    HotelSearchPageResult.new self
  end

  def hotels
    polled? ? @hotels : @all_hotels
  end

  def total_hotels
    @all_hotels.count
  end

  def available_hotels
    @hotels ? @hotels.count : 0
  end

  def min_price
    polled? ? @hotels.min_by {|h| h.offer[:min_price]}.offer[:min_price] : 0
  end

  def max_price    
    polled? ? @hotels.max_by {|h| h.offer[:max_price]}.offer[:max_price] : 0
  end

  def polled?
    @hotels and @hotels.length > 0
  end

  def all_hotels
    @all_hotels ||= Hotel.by_location(location).to_a  
  end

  def search_by_destination    
    threaded {request_expedia_hotels}
    threaded {request_booking_hotels}
    self
  end

  def threaded(&block)
    # return yield
    Thread.new do 
      yield
      ActiveRecord::Base.connection.close
    end
  end

  def reset(provider)
    @hotels ||= []
    results_counter.reset_provider provider
  end

  def finished?
    results_counter.finished?
  end

  def finish(provider)
    results_counter.finish provider
    persist
    Log.debug "#{provider} finished: #{@hotels.count} hotels loaded"
  end

  def page_inc(provider)
    results_counter.inc :expedia
    Log.debug "#{provider} page #{results_counter.page provider}"
  end

  def request_expedia_hotels    
    reset :expedia
    response = Expedia::Search.by_location(location, search_criteria)

    response.page_hotels do |expedia_hotels|
      page_inc :expedia
      add_new_expedia_hotels expedia_hotels
      process_provider_hotels(expedia_hotels) do |provider_hotel|
        all_hotels.find {|hotel| hotel.ean_hotel_id == provider_hotel.id} 
      end
     persist
    end

    finish :expedia
  end


  def add_new_expedia_hotels(expedia_hotels)
    hotel_ids_set = Set.new(expedia_hotels.map(&:id))
    matched_hotels = Set.new(all_hotels.map(&:ean_hotel_id))
    unmatached_hotel_ids = hotel_ids_set.difference(matched_hotels)
    all_hotels.concat  Hotel.where(ean_hotel_id: unmatached_hotel_ids.to_a).to_a  
  end

  def request_booking_hotels
    reset :booking
    response = Booking::Search.by_location(location, search_criteria)

    process_provider_hotels(response.hotels) do |provider_hotel|
      all_hotels.find {|hotel| hotel.booking_hotel_id == provider_hotel.id} 
    end

    finish :booking    
  end

  def process_provider_hotels(provider_hotels, &block)
    provider_hotels.each do |provider_hotel|
      if hotel = yield(provider_hotel)
         add_to_list hotel, provider_hotel
      else
        Log.info "No match for provider: #{provider_hotel.class} hotel_id: #{provider_hotel.id}"
      end
    end
  end

  def add_to_list(hotel, provider_hotel)

    hotel.compare_and_add(provider_hotel, search_criteria)
    return if @hotels.include?(hotel)

    hotel.distance_from_location = hotel.distance_from location
    @hotels << hotel
  end

  def persist
    Rails.cache.write cache_key, self
  end

  def cache_key
    search_criteria.as_json.merge({query:location.slug})
  end


end