class ExpediaWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(cache_key)
    search =  Rails.cache.read cache_key
    return unless search
    provider, key = :expedia, :ean_hotel_id   
    search.reset provider   
    time = Benchmark.realtime do       
      Expedia::Search.by_location(search.location, search.search_criteria).page_hotels do |provider_hotels|
        search.compare_and_persist provider_hotels, key
      end
    end
    Log.info "Realtime comparison of #{provider} for location: #{search.location.description} took #{time}s"    
    search.finish_and_persist provider 
  end


end