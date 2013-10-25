class HotelSearch
  attr_reader :query, :search_criteria, :results_counter, :started

  attr_accessor :total_hotels

  def initialize(query, search_criteria)
    @query, @search_criteria = query, search_criteria
  end

  def self.find_or_create(query, search_criteria)
    cache_key = search_criteria.as_json.merge({query:query})
    Rails.cache.fetch cache_key, expires_in: 5.minutes do 
      Log.info cache_key
      new(query, search_criteria)
    end    
  end

  def start
    return self if @started
    @started = true
    load_all_hotels
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

  def polled?
    @hotels and @hotels.length > 0
  end

  def load_all_hotels
    @all_hotels ||= Hotel.with_images.by_city(query).by_star_ratings(search_criteria.min_stars, search_criteria.max_stars)
  end

  def finished?
    results_counter[:expedia][:finished]
  end

  def search_by_destination
    @hotels = []
    Thread.new do
      request_expedia_hotels
      ActiveRecord::Base.connection.close
    end   
    self
  end

  def request_expedia_hotels
    response = Expedia::HotelRoomSearch.by_destination(query, search_criteria)

    response.page_hotels do |expedia_hotels|
      results_counter[:expedia][:pages] += 1
      Log.debug "#{expedia_hotels.count} Expedia hotels found of page #{results_counter[:expedia][:pages]}"
      expedia_hotels.each do |ex_hotel|
        hotel = @all_hotels.find {|hotel| hotel.ean_hotel_id == ex_hotel.id}
        next unless hotel
        hotel.compare_and_add_hotel ex_hotel 
        @hotels << hotel
      end

     persist
    end

    results_counter[:expedia][:finished] = true
    persist
    Log.debug "#{@hotels.count} Expedia hotels loaded"
  end


  def request_booking_hotels
    booking_hotels = Booking::HotelRoomSearch.by_city_ids(query, search_criteria)
    Log.debug "#{booking_hotels.count} Booking hotels found"
    booking_hotels.each do |booking_hotel|
      hotel = @all_hotels.find {|hotel| hotel.booking_hotel_id == booking_hotel.id}
      next unless hotel
      hotel.compare_and_add_hotel booking_hotel 
      @hotels << hotel
    end

    results_counter[:booking][:finished] = true
    persist
    Log.debug "#{@hotels.count} Booking hotels loaded"
  end

  def persist
    Rails.cache.write cache_key, self
  end

  def cache_key
    search_criteria.as_json.merge({query:query})
  end

  def results_counter
    @results_counter ||={
      expedia:{pages: 0, finished: false},
      booking:{pages: 0, finished: false}
    }
  end

  # def as_json(options={})
  #   Jbuilder.encode do |json|
  #     json.(self, :query, :search_criteria)
  #     json.finished finished?
  #     json.hotels hotels
  #   end
  # end
end