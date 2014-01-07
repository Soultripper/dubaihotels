class HotelWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  attr_accessor :search, :channel

  def perform(cache_key)
    Log.info "------ SEARCH BEGINNING -------- "
    @search =  Rails.cache.read cache_key
    return unless search

    time = Benchmark.realtime{
      threads = []
      threads << threaded {request_booking_hotels}      if @search.include? :booking
      threads << threaded {request_agoda_hotels}        if @search.include? :agoda
      threads << threaded {request_expedia_hotels}      if @search.include? :expedia
      threads << threaded {request_easy_to_book_hotels} if @search.include? :easy_to_book
      threads << threaded {request_splendia_hotels}     if @search.include? :splendia
      Log.debug "Waiting for threads to finish"
      threads.each &:join
    }
    Log.info "------ SEARCH COMPLETED IN #{time} seconds -------- "
    notify
  end

  def threaded(&block)
    thread = Thread.new do 
      yield
      ActiveRecord::Base.connection.close
    end
    thread
  end

  def request_booking_hotels
    hotels_ids = find_hotels_for_provider :booking_hotel_id
    start :booking, :booking_hotel_id do |key|     
      Booking::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
      # Booking::SearchLocation.page_hotels(location, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  rescue Exception => msg  
    error :booking, msg    
  end 

  def request_expedia_hotels
    hotels_ids = find_hotels_for_provider :ean_hotel_id
    start :expedia, :ean_hotel_id do |key|   
      Expedia::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
      # Expedia::Search.by_hotel_ids(hotels_ids, search_criteria).page_hotels do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  # rescue Exception => msg  
    # error :expedia, msg
  end

  def request_easy_to_book_hotels
    hotels_ids = find_hotels_for_provider :etb_hotel_id
    start :easy_to_book, :etb_hotel_id do |key|   
      EasyToBook::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
      # EasyToBook::Search.by_city(@search.location.etb_city_id, @search.search_criteria).page_hotels do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  rescue Exception => msg  
    error :easy_to_book, msg      
  end

  def request_agoda_hotels
    hotels_ids = find_hotels_for_provider :agoda_hotel_id
    start :agoda, :agoda_hotel_id do |key|   
      Agoda::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  rescue Exception => msg  
    error :agoda, msg      
  end

  def request_splendia_hotels
    hotels_ids = find_hotels_for_provider :splendia_hotel_id
    start :splendia, :splendia_hotel_id do |key|   
      Splendia::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  rescue Exception => msg  
    error :splendia, msg      
  end

  def start(provider, key, &block)
    provider, key = provider, key
    @search.reset provider  
    time = Benchmark.realtime { yield key }
    log_and_finish provider, time
  end

  def log_and_finish(provider, time)
    Log.info "Realtime comparison of #{provider} for location: #{location.city}, #{location.country} took #{time}s" 
    @search.finish_and_persist provider
  end

  def error(provider, msg)
    @search.error provider, msg
  end

  def compare_and_persist(provider_hotels, key)
    @search.compare_and_persist provider_hotels, key
    notify
  end

  def search_criteria
    @search.search_criteria
  end

  def location
    @search.location
  end

  def channel
    @search.channel
  end

  def notify
    Log.debug "Notifying channel #{channel} of hotels update. state=#{@search.state}"
    Pusher[channel].trigger('results_update', { key: @search.cache_key})    
  end

  def find_hotels_for_provider(provider_key)
    @hotels_for_location ||= Hotel.by_location(location).to_a
    matches = @hotels_for_location.select {|hotel| hotel[provider_key]}.map &provider_key
    Log.debug "Found #{matches.count} hotels to search for against provider #{provider_key}"
    matches
  end


end