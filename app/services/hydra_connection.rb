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
