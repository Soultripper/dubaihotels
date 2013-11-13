class HotelSearch

  attr_reader :location, :search_criteria, :results_counter, :started

  def initialize(location, search_criteria)
    @results_counter = ResultsCounter.new [:booking]
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
    Log.debug "Search found a total of #{total_hotels} hotels"
    persist
    search_by_destination
    self
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

  def available_hotels
    hotels.count
  end

  def all_hotels
    @all_hotels ||= Hotel.by_location(location).to_a 
  end

  def search_by_destination    
    # threaded {request_expedia_hotels}
    threaded {request_booking_hotels}
  end

  def threaded(&block)
    # return yield
    Thread.new do 
      yield
      ActiveRecord::Base.connection.close
    end
  end

  def reset(provider)
    results_counter.reset_provider provider
  end

  def finished?
    results_counter.finished?
  end

  def finish(provider)
    @hotels = nil
    results_counter.finish provider
    persist
    Log.debug "#{provider} finished: #{hotels.count} hotels loaded"
  end

  def page_inc(provider)
    results_counter.inc provider
    Log.debug "#{provider} page #{results_counter.page provider}"
  end

  # def request_expedia_hotels    
  #   reset :expedia
  #   response = Expedia::Search.by_location(location, search_criteria)

  #   response.page_hotels do |expedia_hotels|
  #     page_inc :expedia
  #     add_new_expedia_hotels expedia_hotels
  #     process_provider_hotels(expedia_hotels) do |provider_hotel|
  #       all_hotels.find {|hotel| hotel.ean_hotel_id == provider_hotel.id} 
  #     end
  #    persist
  #   end

  #   finish :expedia
  # end


  # def add_new_expedia_hotels(expedia_hotels)
  #   hotel_ids_set = Set.new(expedia_hotels.map(&:id))
  #   matched_hotels = Set.new(all_hotels.map(&:ean_hotel_id))
  #   unmatached_hotel_ids = hotel_ids_set.difference(matched_hotels)
  #   all_hotels.concat  Hotel.where(ean_hotel_id: unmatached_hotel_ids.to_a).to_a  
  # end

  def request_booking_hotels
    reset :booking
    booking_hotel_ids = all_hotels.map(&:booking_hotel_id).compact

    time = Benchmark.realtime do 
      Log.debug "Searching #{booking_hotel_ids.count} booking hotels"
      response = Booking::Search.by_hotel_ids_in_parallel(booking_hotel_ids, search_criteria, slice: 250)
      Log.debug "Found #{response.hotels.count} booking hotels"
      compare response.hotels, :booking_hotel_id
    end
    Log.info "Realtime comparison of booking.com took #{time}s"

    
    finish :booking    
  end

  def compare(hotels, key)
    matches = 0
    time = Benchmark.realtime do 
      HotelComparer.compare(all_hotels, hotels, key) do |hotel, provider_hotel|
        matches += 1
        add_to_list(hotel, provider_hotel)
      end    
    end
    puts "Matched and compared #{matches} matches out of #{all_hotels.count} hotels in #{time}s"
  end

  def add_to_list(hotel, provider_hotel)
    hotel.compare_and_add(provider_hotel, search_criteria)
    hotel.distance_from_location = hotel.distance_from(@location) unless hotel.distance_from_location
  end

  def persist
    Rails.cache.write cache_key, self
  end

  def cache_key
    search_criteria.as_json.merge({query:location.slug})
  end


end