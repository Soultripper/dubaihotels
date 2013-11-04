class HotelSearch
  attr_reader :location, :search_criteria, :results_counter, :started

  attr_accessor :total_hotels

  def initialize(location, search_criteria)
    @location, @search_criteria = location, search_criteria
  end

  def self.find_or_create(location, search_criteria)
    cache_key = search_criteria.as_json.merge({query:location.slug})
    Rails.cache.fetch cache_key, expires_in: 5.minutes do 
      Log.info cache_key
      new(location, search_criteria)
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

  def city
    location.city
  end

  def city_id
    location.city_id
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
    @all_hotels ||= Hotel.with_images.by_location(location).by_star_ratings(search_criteria.min_stars, search_criteria.max_stars)
  end

  def finished?
    results_counter[:booking][:finished] && results_counter[:expedia][:finished]
  end

  def search_by_destination
    @hotels = []

    threaded {request_expedia_hotels}
    threaded {request_booking_hotels}
    self
  end

  def threaded(&block)
    # yield
    Thread.new do 
      yield
      ActiveRecord::Base.connection.close
    end
  end

  def request_expedia_hotels
    response = Expedia::Search.by_destination(city, search_criteria)

    response.page_hotels do |expedia_hotels|
      results_counter[:expedia][:pages] += 1
      Log.debug "#{expedia_hotels.count} Expedia hotels found of page #{results_counter[:expedia][:pages]}"

      expedia_hotels.each do |ex_hotel|
        hotel = @all_hotels.find {|hotel| hotel.ean_hotel_id == ex_hotel.id}
        add_to_list hotel, ex_hotel
      end

     persist
    end

    results_counter[:expedia][:finished] = true
    persist
    Log.debug "#{@hotels.count} Expedia hotels loaded"
  end


  def request_booking_hotels
    # hotel_ids = BookingHotel.where(city_id: city_id).limit(200).pluck :id
    # response = Booking::HotelRoomSearch.by_hotel_ids(hotel_ids, search_criteria)
    response = Booking::Search.by_city_ids(city_id, search_criteria)
    response.hotels.each do |booking_hotel|
      hotel = @all_hotels.find {|hotel| hotel.booking_hotel_id == booking_hotel.id} if !hotel
      add_to_list hotel, booking_hotel
    end

    results_counter[:booking][:finished] = true
    persist
    Log.debug "#{@hotels.count} Booking hotels loaded"
  end

  def add_to_list(hotel, provider_hotel)
    return nil unless hotel
    hotel.compare_and_add provider_hotel 
    return if @hotels.include?(hotel)
    hotel.distance_from_location = hotel.distance_from location
    @hotels << hotel
  end

  def find_or_add(hotel_collection, provider_hotel)
    hotel_collection.find {|hotel| hotel.booking_hotel_id == provider_hotel.id}
  end

  def persist
    Rails.cache.write cache_key, self
  end

  def cache_key
    search_criteria.as_json.merge({query:location.slug})
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