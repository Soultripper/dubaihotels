class HotelWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  attr_accessor :search

  def perform(cache_key)
    @search = Rails.cache.read cache_key
    return unless search


    Log.info "------ SEARCH BEGINNING (#{location.slug}) -------- "
    print_sys_info
    #MemTool.start("HotelSearch-#{cache_key}")

    threads = []
    time = Benchmark.realtime{
      HotelsConfig.providers.each { |provider| threads << threaded(provider) }
      Log.debug "Waiting for threads to finish"
      threads.each &:join
    }
    notify
    #MemTool.stop

    ObjectSpace.garbage_collect
    print_sys_info
    Log.info "------ SEARCH COMPLETED IN #{time} seconds (state=#{@search.state}) -------- "
    

  end

  def print_sys_info
    Log.info "Sys info: #{Utilities.mem_report}"
  end

  def threaded(provider)
    thread = Thread.new do 
      request_hotels(provider)
      ActiveRecord::Base.connection.close
    end
    thread
  end

  def request_hotels(provider)
    return unless @search.include? provider
    search.reset provider  
    find_hotels_for provider
    @search.finish_and_persist provider   
  end

  def find_hotels_for(provider)   
    hotels_ids = @search.provider_ids_for(provider)

    if hotels_ids.length==0
      Log.info "No provider #{provider.upcase} hotel ids found"
      return 
    end

    stats = {}
    time = Benchmark.realtime do 
      stats = search_method_for(provider).request_hotels(search_criteria, hotels_ids) do |provider_hotels|
        notify if @search.compare_and_persist(provider_hotels, provider)
      end
    end


    Log.info "#{provider.upcase} Finished: time=#{time.round(2)}s requests=#{stats[:requests]} size=#{stats[:size]}Mb searched=#{hotels_ids.count} found=#{stats[:found]} avg_time=#{stats[:avg_time]}s max_time=#{stats[:max_time]}s percentage=#{stats[:percentage]}%" if stats

  rescue => msg  
    error provider, msg   
  end

  def error(provider, msg)
    @search.error_and_persist provider, msg
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
    #Log.debug "Notifying channel #{channel} for hotels update. state=#{@search.state}"
    Pusher[channel].trigger_async('results_update', { key: @search.cache_key})    
  end

  def search_method_for(provider)
    "#{HotelsConfig::PROVIDER_IDS[provider]}::SearchHotel".constantize
  end

end