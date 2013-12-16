require 'location'

class HotelSearch
  extend Forwardable
  attr_reader :location, :search_criteria, :results_counter, :started, :use_cache, :channel

  def_delegators :@results_counter, :reset, :page_inc, :finished?, :finish, :include?

  PROVIDERS = [:booking, :expedia, :easy_to_book]
  # PROVIDERS = [:booking]

  def initialize(location, search_criteria, use_cache=true)
    @use_cache = use_cache
    @results_counter = ResultsCounter.new PROVIDERS
    @location, @search_criteria = location, search_criteria
  end

  def self.find_or_create(location, search_criteria)
    HotelSearch.new(location, search_criteria).find_or_create   
  end

  def find_or_create
    Rails.cache.fetch cache_key, force: !@use_cache do 
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
    search
  end

  def all_hotels
    @all_hotels ||= Hotel.by_location(location).limit(200).to_a 
  end

  def search      
    return unless search_criteria.valid?
    HotelWorker.perform_async cache_key 
    # HotelWorker.new.perform cache_key
    self
  end

  def results
    results = {
      total: total_hotels,
      location: location,
      channel: channel,
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

  def compare_and_persist(hotels, key)
    matches = 0
    time = Benchmark.realtime do 
      HotelComparer.compare(all_hotels, hotels, key) do |hotel, provider_hotel|
        matches += 1
        add_to_list(hotel, provider_hotel)
      end    
    end
    persist
    Log.info "Matched, persisted, notified and compared #{matches} matches out of #{all_hotels.count} hotels in #{time}s"
  end

  def add_to_list(hotel, provider_hotel)
    hotel.compare_and_add(provider_hotel, search_criteria, location)
    hotel.distance_from_location = hotel.distance_from(location) unless hotel.distance_from_location
  end

  def finish_and_persist(provider)
    finish provider
    persist
    Log.debug "COMPLETE - #{provider.upcase}: #{hotels.count} hotels compared"
    hotels.count
  end

  def error(provider, msg)
    finish provider
    persist    
    Log.error "ERROR ----- Provider #{provider} errored. #{msg}" 
  end

  def persist
    return unless @use_cache
    Rails.cache.write(cache_key, self, expires_in: 5.minutes, race_condition_ttl: 15)
  end

  def cache_key
    search_criteria.as_json.merge({query:location.slug})
  end

  def channel
    search_criteria.channel_search location
  end
end