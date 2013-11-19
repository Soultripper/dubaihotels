class BookingWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(cache_key)
    search =  Rails.cache.read cache_key
    return unless search

    provider, key = :booking, :booking_hotel_id   
    search.reset provider   
    time = Benchmark.realtime do       
      Booking::SearchCity.page_hotels(search.location.city_id, search.search_criteria) do |provider_hotels|
        search.compare_and_persist provider_hotels, key
      end
    end
    Log.info "Realtime comparison of #{provider} for location: #{search.location.city}, #{search.location.country} took #{time}s"    
    search.finish_and_persist provider 
  end


end