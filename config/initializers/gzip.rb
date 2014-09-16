require 'faraday'
require 'zlib'
 
module FaradayMiddleware
  class Gzip < Faraday::Response::Middleware
 
    def on_complete(env)
      encoding = env[:response_headers]['content-encoding'].to_s.downcase
      case encoding
        when 'gzip'
          env[:body] = Zlib::GzipReader.new(StringIO.new(env[:body]), encoding: 'ASCII-8BIT').read
          # env[:response_headers].delete('content-encoding')
          #Log.debug "GUnzipped (#{env[:body].length} bytes)" 
        when 'deflate'
          env[:body] = Zlib::Inflate.inflate(env[:body])
          # env[:response_headers].delete('content-encoding')
          #Log.debug "Deflated (#{env[:body].length} bytes)"    
      end
    end
 
  end
end
 
Faraday::Response.register_middleware :gzip => FaradayMiddleware::Gzip
Faraday::Adapter.register_middleware :my_typhoeus => MyTyphoeusAdapter