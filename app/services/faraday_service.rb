module FaradayService
  extend self


  def HttpGZip(url)
    Faraday.new(url: url) do |faraday|
      faraday.headers['Accept-Encoding'] = 'gzip,deflate'
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.response :gzip 
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end