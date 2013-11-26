class HotelWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  attr_accessor :search

  def perform(cache_key)
    @search =  Rails.cache.read cache_key
    return unless search

    threads = []
    threads << threaded {request_booking_hotels}      if @search.include? :booking
    threads << threaded {request_expedia_hotels}      if @search.include? :expedia
    threads << threaded {request_easy_to_book_hotels} if @search.include? :easy_to_book
    Log.debug "Waiting for threads to finish"
    threads.each &:join
  end

  def threaded(&block)
    thread = Thread.new do 
      yield
      ActiveRecord::Base.connection.close
    end
    thread
  end

  def request_booking_hotels
    start :booking, :booking_hotel_id do |key|     
      Booking::SearchCity.page_hotels(location.city_id, search_criteria) do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  end 

  def request_expedia_hotels
    start :expedia, :ean_hotel_id do |key|   
      Expedia::Search.by_location(location, search_criteria).page_hotels do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
  end

  def request_easy_to_book_hotels
    hotels_ids = location.hotel_ids_for :etb_hotel_id
    start :easy_to_book, :etb_hotel_id do |key|   
      EasyToBook::SearchHotel.page_hotels(hotels_ids, search_criteria) do |provider_hotels|
      # EasyToBook::Search.by_city(@search.location.etb_city_id, @search.search_criteria).page_hotels do |provider_hotels|
        compare_and_persist provider_hotels, key
      end
    end
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

  def compare_and_persist(provider_hotels, key)
    @search.compare_and_persist provider_hotels, key
  end

  def search_criteria
    @search.search_criteria
  end

  def location
    @search.location
  end


end