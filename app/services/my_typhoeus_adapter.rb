class MyTyphoeusAdapter < Faraday::Adapter::Typhoeus
  def request(*)
    request = super
    request.options.merge!(:nosignal => true, ssl_verifypeer: false)
    request
  end
end