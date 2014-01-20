class HotelWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  attr_accessor :search, :channel

  def perform(cache_key)
    Log.info "------ SEARCH BEGINNING -------- "
    @search =  Rails.cache.read cache_key
    return unless search
    populate_provider_ids

    time = Benchmark.realtime{
      threads = []
      threads << threaded {request_booking_hotels}      if @search.include? :booking
      threads << threaded {request_agoda_hotels}        if @search.include? :agoda
      threads << threaded {request_expedia_hotels}      if @search.include? :expedia
      threads << threaded {request_easy_to_book_hotels} if @search.include? :easy_to_book
      threads << threaded {request_splendia_hotels}     if @search.include? :splendia
      threads << threaded {request_laterooms_hotels}    if @search.include? :laterooms
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
    hotels_ids = find_hotels_for_provider :booking
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
    hotels_ids = find_hotels_for_provider :expedia
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
    hotels_ids = find_hotels_for_provider :easy_to_book
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
    hotels_ids = find_hotels_for_provider :agoda
    start :agoda, :agoda_hotel_id do |key|   
      Agoda::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  rescue Exception => msg  
    error :agoda, msg      
  end

  def request_splendia_hotels
    hotels_ids = find_hotels_for_provider :splendia
    start :splendia, :splendia_hotel_id do |key|   
      Splendia::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  rescue Exception => msg  
    error :splendia, msg      
  end

  def request_laterooms_hotels
    hotels_ids = find_hotels_for_provider :laterooms
    start :laterooms, :laterooms_hotel_id do |key|   
      LateRooms::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  # rescue Exception => msg  
    # error :laterooms, msg      
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
    Log.debug "#{provider_hotels.count} hotels to compared for #{key}"
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
    Log.debug "Notifying channel #{channel} for hotels update. state=#{@search.state}"
    Pusher[channel].trigger_async('results_update', { key: @search.cache_key})    
  end

  def populate_provider_ids
    @bucket_hotels ||= bucket_hotels
  end

  def bucket_hotels
    provider_ids = {}
    HotelsConfig::PROVIDER_IDS.each {|key, id| provider_ids[key] = []}
    @search.hotels.each do |hotel_comparison|
      HotelsConfig::PROVIDER_IDS.each do |key, id|
        provider_ids[key] << hotel_comparison[id] if hotel_comparison[id]
      end
    end
    provider_ids    
  end

  # def find_hotels_for_provider(provider_key)
  #   throw @search.hotels
  #   @hotels_for_location ||= Hotel.by_location(location).to_a
  #   matches = @hotels_for_location.select {|hotel| hotel[provider_key]}.map &provider_key
  #   Log.debug "Found #{matches.count} hotels to search for against provider #{provider_key}"
  #   matches
  # end

  def find_hotels_for_provider(provider_key)
    matches = @bucket_hotels[provider_key] || []

    Log.debug "Found #{matches.count} hotels to search for against provider #{provider_key}"
    matches
  end


end