class HotelWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  attr_accessor :search

  def perform(cache_key)
    @search =  Rails.cache.read cache_key
    return unless search

    threads = []
    threads << threaded {request_booking_hotels} if @search.include? :booking
    threads << threaded {request_expedia_hotels} if @search.include? :expedia
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


  def request_expedia_hotels
    provider, key = :expedia, :ean_hotel_id
    @search.reset provider
    time = Benchmark.realtime do 
      Expedia::Search.by_location(@search.location, @search.search_criteria).page_hotels do |provider_hotels|
        @search.compare_and_persist provider_hotels, key
      end
    end
    Log.info "Realtime comparison of #{provider} for location: #{@search.location.city}, #{@search.location.country} took #{time}s" 
    @search.finish_and_persist provider
  end

  def request_booking_hotels
    provider, key = :booking, :booking_hotel_id
    @search.reset provider   
    time = Benchmark.realtime do       
      Booking::SearchCity.page_hotels(@search.location.city_id, @search.search_criteria) do |provider_hotels|
        @search.compare_and_persist provider_hotels, key
      end
    end
    Log.info "Realtime comparison of #{provider} for location: #{@search.location.city}, #{@search.location.country} took #{time}s" 
    @search.finish_and_persist provider 
  end


end