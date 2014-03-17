require 'location'

class HotelSearch
  extend Forwardable
  attr_reader :location, :search_criteria, :results_counter, :state, :use_cache, :channel

  def_delegators :@results_counter, :reset, :page_inc, :finished?, :finish, :include?

  PROVIDERS = [:booking, :agoda, :expedia, :easy_to_book, :splendia, :laterooms]
  # PROVIDERS = [:splendia]

  def initialize(location, search_criteria = SearchCriteria.new, use_cache=true)
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
    return self if @state
    @state = :searching
    all_hotels
    Log.debug "Hotel Search: #{total_hotels} hotels to search"
    persist
    search
  end

  def all_hotels
    @all_hotels ||= HotelComparisons.by_location(location).to_a 
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
      state: @state
    }
    cur_hotels = loaded_hotels
    cur_hotels = (cur_hotels.length > 0 or state == :finished) ? cur_hotels : all_hotels
    HotelSearchPageResult.new cur_hotels.clone, results
  end


  def hotels
    @hotels ||= compared_hotels
  end

  def loaded_hotels
    compared_hotels.select {|h| h.has_a_deal?}
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

        common_provider_hotel = provider_hotel.commonize(search_criteria, location)

        if key==:booking_hotel_id
          common_provider_hotel[:link] = search_criteria.booking_link(hotel)
        end

        if key==:laterooms_hotel_id and common_provider_hotel
          common_provider_hotel[:link] = search_criteria.laterooms_link(hotel)
        end

        matches += 1 if add_to_list(hotel, common_provider_hotel)

        if(key==:ean_hotel_id)
          common_provider_hotel = provider_hotel.commonize_to_hotels_dot_com(search_criteria, location)
          add_to_list(hotel, common_provider_hotel)
        end

      end    
    end
    persist
    Log.info "Matched, persisted, notified and compared #{matches} matches out of #{all_hotels.count} hotels in #{time}s"
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
    Rails.cache.write(cache_key, self, expires_in: 10.minutes, race_condition_ttl: 60)
  end

  def cache_key
    search_criteria.as_json.merge({query:location.unique_id})
  end

  def channel
    search_criteria.channel_search location
  end
end