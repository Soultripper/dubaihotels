class ProviderHotelSearch

  attr_reader :search_criteria, :ids 
  
  def initialize(search_criteria, ids = nil)
    @search_criteria, @ids = search_criteria, ids
  end

  def self.request_hotels( search_criteria, ids, options={}, &block)
    new(search_criteria, ids).request_hotels(options, &block)
  end

  def slice_size; 150; end
  def first_slice_size; 30; end

  def fetch_hotels(hotel_ids=nil, &success_block)
    request(hotel_ids, &success_block).run.handled_response
  end

  def request_hotels(options={}, &block)

    requests = []

    HydraConnection.in_parallel do

      requests << hydra_request(ids.take(first_slice_size), options, &block)  

      ids.drop(first_slice_size).each_slice(slice_size) do |hotel_ids| 
        requests << hydra_request(hotel_ids, options, &block)
      end

      requests
    end
    requests = nil
    ids = nil
  end

  def hydra_request(hotel_ids, options, &process_hotels)
    req = request(hotel_ids, options, &process_hotels) 

    provider = self.class.name

    req.on_complete do |response|
      Log.debug "#{provider} response complete: uri=#{response.request.base_url}, time=#{response.total_time}sec, code=#{response.response_code}, message=#{response.return_message}"
      if response.success?
        begin
          hotels_list = self.create_hotels_list response.body
        rescue => msg
          Log.error "#{provider} error response: #{response.body}, #{msg}"
          nil  
        end
        if hotels_list and hotels_list.hotels.count > 0                
          block_given? ? (yield hotels_list.hotels) : hotels_list
        end
                 
      elsif response.timed_out?
        Log.error ("#{provider} request timed out, uri=#{response.request.url}")
      elsif response.code == 0
        Log.error("#{provider}: response_code=0, msg=#{response.return_message}")
      else
        Log.error("#{provider} HTTP request failed: #{response.code}, body=#{response.body}")
      end
      response = nil
    end

    # req.on_success do |res|
    #   Log.info "yeah"
    # end

    # req.on_failure do |response|
    #   Log.error("#{provider} HTTP request failed: #{response.code}, body=#{response.body}")
    # end

    req
  end

  def xml_headers
    {
      'Content-Type'=> 'text/xml;charset=utf-8'
    }
  end

end