class ProviderHotelSearch

  attr_reader :search_criteria, :ids
  
  def initialize(search_criteria, ids = nil)
    @search_criteria, @ids, = search_criteria, ids
    @total_size, @total_hotels, @total_time, @max_time = 0, 0, 0, 0

  end

  def self.request_hotels( search_criteria, ids, options={}, &block)
    new(search_criteria, ids).request_hotels(options, &block)
  end

  def slice_size; 150; end
  def first_slice_size; 25; end

  def fetch_hotels(count=nil,options={}, &success_block)
      hotel_ids = count ? ids.take(count) : ids
      hydra_request(hotel_ids, options).run.handled_response
    end

  def request_hotels(options={}, &block)
    @total_size, @total_hotels, @total_time, @max_time = 0, 0, 0, 0

    requests = []

    time = Benchmark.realtime do 
      HydraConnection.in_parallel do
        requests << hydra_request(ids.take(first_slice_size), options, &block)  
        ids.drop(first_slice_size).each_slice(options[:slice_size] || slice_size) do |hotel_ids| 
          requests << hydra_request(hotel_ids, options, &block)
        end
        requests
      end
    end

    percentage_found = (@total_hotels/ids.count.to_f * 100).round(2)
    avg_time = (@total_time / requests.count).round(2)



    stats = {
      time: time.round(2),
      searched: ids.count,
      requests: requests.count,
      size: (@total_size.to_f / 1000000.to_f).round(2),
      found: @total_hotels,
      avg_time:avg_time,
      max_time: @max_time.round(2),
      percentage: percentage_found
    }

    requests = nil
    ids = nil
    stats

  end

  def hydra_request(hotel_ids, options, &process_hotels)
    req = request(hotel_ids, options, &process_hotels) 

    provider = self.class.name

    req.on_success do |response|
      begin
        hotels_list = self.create_hotels_list response.body
        response = nil
      rescue => msg
        Log.error "#{provider} could not convert response to hotels: #{response.body}, #{msg}"
        nil  
      end
      if hotels_list and hotels_list.hotels.count > 0      
        @total_hotels += hotels_list.hotels.count
        block_given? ? (yield hotels_list.hotels) : hotels_list
      end    
      hotels_list      
    end

    req.on_complete do |response|
      size = response.body.size
      @total_size += size
      @total_time += response.total_time 
      @max_time = response.total_time > @max_time ? response.total_time : @max_time
      msg = "#{provider} response complete: message=#{response.return_message} size=#{size/1000}Kb time=#{response.total_time.round(2)}s code=#{response.response_code} uri=#{response.request.base_url}"               
      if response.timed_out? || response.code != 200
        Log.error msg
        nil
      else
        #Log.debug msg
        nil
      end
    end

    req
  end

  def xml_headers
    {
      'Content-Type'=> 'text/xml;charset=utf-8'
    }
  end

end