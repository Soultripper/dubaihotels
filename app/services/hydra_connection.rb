module HydraConnection
  extend self



  def in_parallel(&block)
     hydra = Typhoeus::Hydra.hydra
     yield.each do |req| 
      Log.debug "Queuing #{req.base_url}"
      hydra.queue req
      end

     hydra.run
  end

  def post(url, options={})
    Typhoeus::Request.new(
      url,
      followlocation: true,
      accept_encoding: "gzip,deflate",
      method: :post,
      body: options[:body],
      params: options[:params],
      headers: options[:headers],
      timeout: 15,
      connecttimeout: 10
    )
  end

  def get(url, options={})
    Typhoeus::Request.new(
      url,
      followlocation: true,
      accept_encoding: "gzip,deflate",
      method: :get,
      body: options[:body],
      params: options[:params],
      headers: options[:headers],
      timeout: 15,
      connecttimeout: 10
    )
  end


  # def hotels_request(req, provider_class, &process_hotels)
  #   provider = provider_class.class.name

  #   # req.on_success do |res|
  #   #   Log.info "yeah"
  #   # end

  #   req.on_complete do |response|
  #     Log.debug "#{provider} response complete: uri=#{response.request.base_url}, time=#{response.total_time}sec, code=#{response.response_code}, message=#{response.return_message}"
  #     if response.success?
  #       begin
  #         hotels_list = provider_class.create_hotels_list response.body
  #       rescue => msg
  #         Log.error "#{provider} error response: #{response.body}, #{msg}"
  #         nil  
  #       end
  #       return nil unless hotels_list and hotels_list.hotels.count > 0                
  #       block_given? ? (yield hotels_list.hotels) : hotels_list
  #       end         
  #     elsif response.timed_out?
  #       Log.error ("#{provider} request timed out")
  #     elsif response.code == 0
  #       Log.error("#{provider}: Response code = 0, msg=#{response.return_message}")
  #     else
  #       Log.error("#{provider} HTTP request failed: #{response.code}, body=#{response.body}")
  #     end
  #   end

  #   # req.on_failure do |response|
  #   #   Log.error("#{provider} HTTP request failed: #{response.code}, body=#{response.body}")
  #   # end

  #   req
  # end

end


# HyrdaConnection.in_parallel do
#   ids.each_slice((options[:slice] || DEFAULT_SLICE)) do |sliced_ids|
#     req = HyrdaClientAsync.post Booking::Client.url + '/bookings.getBlockAvailability', :body=> search_params.merge(hotel_params(sliced_ids)
#     req.on_complete do |response|
#       hotels = Booking::HotelListResponse.new(JSON.parse(response.body), 1)
#       yield hotels if block_given?
#     end
#     requests << req
#   end
# end
