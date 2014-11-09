class HotelWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  attr_accessor :search

  def perform(cache_key)
    @search = Rails.cache.read cache_key
    return unless search


    Log.info "-- BEGINNING (#{location.slug}) --"
    print_sys_info
    #MemTool.start("HotelSearch-#{cache_key}")

    threads = []
    HotelsConfig.providers.each { |provider| threads << threaded(provider) }
    Log.debug "Waiting for threads to finish"
    threads.each &:join
    notify
    #MemTool.stop

    print_sys_info
    Log.info"-- COMPLETED IN #{stats_agg[:max_time]} seconds (state=#{@search.state}) providers=#{stats_agg[:count]} requests=#{stats_agg[:requests]} size=#{stats_agg[:size].round(2)}Mb searched=#{stats_agg[:searched]} found=#{stats_agg[:found]} avg_time=#{stats_agg[:avg_time]}s max_time=#{stats_agg[:max_time]}s percentage=#{stats_agg[:percentage]}% --"
    

  end

  def stats_agg
    @stats_agg ||= {
      count: 0,
      time: 0,
      max_time: 0,
      requests: 0,
      size: 0,
      searched: 0,
      found: 0,
      requests: 0,
      percentage_found: 0,
      avg_time: 0
    }
  end

  def print_sys_info
    ObjectSpace.garbage_collect
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

    options = {norooms: true}

    stats = search_method_for(provider).request_hotels(search_criteria, hotels_ids, options) do |provider_hotels|
      notify if @search.compare_and_persist(provider_hotels, provider)
    end

    aggregate_stats stats
    Log.info "#{provider.upcase} Finished: time=#{stats[:time]}s requests=#{stats[:requests]} size=#{stats[:size]}Mb searched=#{stats[:searched]} found=#{stats[:found]} avg_time=#{stats[:avg_time]}s max_time=#{stats[:max_time]}s percentage=#{stats[:percentage]}%" if stats

  rescue => msg  
    error provider, msg   
  end

  def aggregate_stats(stats)
    stats_agg[:count]     += 1
    return unless stats
    stats_agg[:max_time]  =  stats[:max_time] > stats_agg[:max_time] || 0 ? stats[:max_time] :  stats_agg[:max_time]
    stats_agg[:requests]  += stats[:requests]
    stats_agg[:size]      += stats[:size].round(2)
    stats_agg[:searched]  += stats[:searched]
    stats_agg[:found]     += stats[:found]
    stats_agg[:requests]  += stats[:requests]
    stats_agg[:percentage] = (stats_agg[:found]/stats_agg[:searched].to_f * 100).round(2)
    stats_agg[:avg_time] = (stats_agg[:max_time] /  stats_agg[:count]).round(2)
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