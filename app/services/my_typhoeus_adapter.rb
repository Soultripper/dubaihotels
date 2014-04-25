class MyTyphoeusAdapter < Faraday::Adapter::Typhoeus
  def request(*)
    request = super
    request.options.merge!(:nosignal => true)
    request.ssl_verifypeer = false
    request
  end
end