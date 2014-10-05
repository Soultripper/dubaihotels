require 'location'
require 'digest/bubblebabble'

class HotelSearch
  extend Forwardable
  attr_reader :location, :search_criteria, :results_counter, :state, :use_cache, :channel

  def_delegators :@results_counter, :reset, :page_inc, :finished?, :finish, :include?

  def initialize(location, search_criteria = SearchCriteria.new, use_cache=true)
    @use_cache = use_cache
    @results_counter = ResultsCounter.new 
    @location, @search_criteria = location, search_criteria
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
      cache_key: cache_key.to_s
    }

    HotelSearchPageResult.new current_hotels.clone, results
  end

  def provider_ids_for(provider)
    @hash_hotels.provider_ids_for provider
  end


  def valid?
    search_criteria.valid? and location
  end

  def current_hotels
    (matched_hotels.length > 0 or state == :finished) ? matched_hotels : @hash_hotels.hotel_comparisons
  end

  def matched_hotels
    _matched_hotels ||= @hash_hotels.hotels_with_deals(location.hotel? ? location.slug : nil)
  end

  def hotels
    _hotels ||= @hash_hotels.hotel_comparisons
  end

  def total_hotels
    @hash_hotels.hotels.count
  end

  def compare_and_persist(provider_hotels_found, provider)
    @state = :searching
    matches = 0
    time = Benchmark.realtime do 
      provider_hotels_found.each do |provider_hotel|
        matches += 1 if add_found_hotel(provider_hotel, provider) 
      end    
    end
    persist
    Log.info "Processed #{matches} matches for #{provider.upcase} out of #{total_hotels} hotels in #{time}s"
  end

  def find_hotel_for(provider, provider_hotel_id)
    @hash_hotels.find_hotel_for(provider, provider_hotel_id)
  end

  def add_found_hotel(provider_hotel, provider)
    hotel = find_hotel_for provider, provider_hotel.id
    return unless hotel and provider_hotel
    common_provider_hotel = provider_hotel.commonize(search_criteria, location)

    return unless common_provider_hotel
    deal = hotel.find_provider_deal(provider)
    if provider==:booking
      common_provider_hotel[:link] = search_criteria.booking_link(deal)
      set_rooms_link(common_provider_hotel)
    elsif provider==:laterooms
      common_provider_hotel[:link] = search_criteria.laterooms_link(deal)
      set_rooms_link(common_provider_hotel)
    end

    add_to_list(hotel, common_provider_hotel)
  end

  def set_rooms_link(hotel_hash)
    hotel_hash[:rooms].each {|room| room[:link] = hotel_hash[:link]}
  end

  def add_to_list(hotel_comparison, common_provider_hotel)
    return false unless common_provider_hotel
    hotel_comparison.compare_and_add(common_provider_hotel)
    hotel_comparison.distance_from_location = hotel_comparison.distance_from(location) unless hotel_comparison.distance_from_location

    true
  end

  def finish_and_persist(provider)
    finish provider
    @state = finished? ? :finished : @state
    persist
    hotels.count
  end

  def error(provider, msg)
    finish provider
    persist    
    Log.error "ERROR ----- Provider #{provider.upcase} errored. #{msg}" 
  end

  def persist
    return unless @use_cache
    Rails.cache.write(cache_key, self, expires_in: HotelsConfig.cache_expiry, race_condition_ttl: 60)
  end

  def cache_key
    @cache_key ||= Digest::MD5.hexdigest(search_criteria.as_json.merge({query:location.unique_id}).to_s)
  end

  def channel
    search_criteria.channel_search location
  end

  protected


  def hash_hotels
    @hash_hotels = HotelsHash.by_location(location) 
  end

  def search      
    # HotelWorker.perform_async cache_key 
    HotelWorker.new.perform cache_key
    self
  end

end