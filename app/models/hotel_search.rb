require 'location'
require 'digest/bubblebabble'

class HotelSearch
  extend Forwardable
  attr_reader :location, :search_criteria, :results_counter, :state, :use_cache, :channel, :timestamp, :search_details, :hashed_hotels

  def_delegators :@results_counter, :reset, :page_inc, :finished?, :finish, :include?, :error
  def_delegators :@search_details, :search_criteria, :location, :valid?

  def initialize(location, search_criteria = SearchCriteria.new, use_cache=true)
    @use_cache = use_cache
    @results_counter = ResultsCounter.new 
    @search_details = SearchDetails.new(search_criteria, location)
  end

  def self.by_location_slug(slug)
    find_or_create Location.find_by_slug(slug), SearchCriteria.from_tomorrow
  end


  def self.find_or_create(location, search_criteria)
    HotelSearch.new(location, search_criteria).find_or_create   
  end

  def self.find(cache_key)
    Rails.cache.fetch cache_key if cache_key
  end

  def find_or_create
    Rails.cache.fetch cache_key, force: !@use_cache do 
      Log.info "Starting new search: #{cache_key}"
      self
    end      
  end

  def start
    return self if @state or !valid?
    @state = :new_search
    hash_hotels
    Log.debug "Hotel Search: #{total_hotels} hotels to search"
    persist
    search
  end

  def results
    results = {
      total: total_hotels,
      location: location,
      channel: channel,
      search_criteria: search_criteria,
      state: @state,
      cache_key: cache_key.to_s,
      timestamp: @timestamp
    }

    HotelSearchPageResult.new current_hotels, results
  end

  def provider_ids_for(provider)
    @hashed_hotels.provider_ids_for provider
  end

  def current_hotels
    (matched_hotels.length > 0 or state == :finished) ? matched_hotels : @hashed_hotels.hotel_comparisons
  end

  def matched_hotels
    _matched_hotels ||= @hashed_hotels.hotels_with_deals(location.hotel? ? location.slug : nil)
  end

  def hotels
    _hotels ||= @hashed_hotels.hotel_comparisons if @hashed_hotels
  end

  def total_hotels
    @hashed_hotels.hotels.count
  end

  def compare_and_persist(found_provider_hotels, provider)
    @state = :searching    
    hotels_compared = HotelComparer.compare(@hashed_hotels, found_provider_hotels, provider, search_details)  
    persist if hotels_compared    
  end

  def finish_and_persist(provider)
    finish provider
    @state = finished? ? :finished : @state
    persist
    hotels.count
  end



  def error_and_persist(provider, msg)
    error provider
    persist    
    Log.error "ERROR ----- Provider #{provider.upcase} errored. #{msg}" 
  end

  def persist
    return unless @use_cache
    @timestamp = DateTime.now.utc.to_f
    Rails.cache.write(cache_key, self, expires_in: HotelsConfig.cache_expiry, race_condition_ttl: 60)
    true
  end

  def cache_key
    @cache_key ||= Digest::MD5.hexdigest(search_criteria.as_json.merge({query:location.unique_id}).to_s)
  end

  def channel
    search_criteria.channel_search location
  end

  protected

  def hash_hotels
    @hashed_hotels = HotelsHash.by_location(location) 
  end

  def search      
    HotelWorker.perform_async cache_key     
    #HotelWorker.new.perform cache_key
    self
  end

end