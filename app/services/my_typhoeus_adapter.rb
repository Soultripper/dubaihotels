class MyTyphoeusAdapter < Faraday::Adapter::Typhoeus
  def request(*)
    request = super
    request.options.merge!(:nosignal => true)
    request
  end
end