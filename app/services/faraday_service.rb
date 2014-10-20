module FaradayService
  extend self


  def HttpGZip(url)
    Faraday.new(url: url) do |faraday|
      faraday.headers['Accept-Encoding'] = 'gzip,deflate'
      faraday.request  :url_encoded             # form-encode POST params
      #faraday.response :logger                  # log requests to STDOUT
      faraday.response :gzip 
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end


  def http(url)
    Faraday.new(url: url) do |faraday|
      faraday.headers['Accept-Encoding'] = 'gzip,deflate'
      faraday.options[:nosignal] = true
      faraday.request  :retry,   1   # times
      faraday.request  :url_encoded             # form-encode POST params
      faraday.options[:timeout] = 15 
      faraday.options[:open_timeout] = 20  
      #faraday.response :logger                  # log requests to STDOUT
      faraday.response :gzip 
      # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.adapter  :my_typhoeus
    end
  end

end