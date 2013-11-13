require 'faraday'
require 'expedia/http_service/response'
require 'typhoeus/adapters/faraday'

module Expedia
  module HTTPService

    API_SERVER = 'api.ean.com'
    RESERVATION_SERVER = 'book.api.ean.com'

    class << self

      def server(options = {})
        server = "#{options[:reservation_api] ? RESERVATION_SERVER : API_SERVER}"
        "#{options[:use_ssl] ? "https" : "http"}://#{server}"
      end

      def http(server, options={})
        Faraday.new(server, options) do |faraday|
          faraday.headers['Accept-Encoding'] = 'gzip,deflate'
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to STDOUT
          faraday.response :gzip 
          # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          faraday.adapter  :typhoeus
        end
      end

      def make_request(path, args, verb, options = {})
        args.merge!(common_parameters)
        request_options = {:params => (verb == :get ? args : {})}
        conn = http(server(options), request_options)
        conn.send(verb, path, (verb == :post ? args : {}))
      end

      def create_response(response)
        # Expedia::Utils.debug "\nExpedia [#{verb.upcase}] - #{server(options) + path} params: #{args.inspect} : #{response.status}\n"
        response = Expedia::HTTPService::Response.new(response.status.to_i, response.body, response.headers)
        response.exception? ? Expedia::APIError.new(response.status, response.body) : response        
      end

      def encode_params(param_hash)
        ((param_hash || {}).sort_by{|k, v| k.to_s}.collect do |key_and_value|
           key_and_value[1] = MultiJson.dump(key_and_value[1]) unless key_and_value[1].is_a? String
           "#{key_and_value[0].to_s}=#{CGI.escape key_and_value[1]}"
        end).join("&")
      end

      def signature
        if Expedia.cid && Expedia.api_key && Expedia.shared_secret
          Digest::MD5.hexdigest(Expedia.api_key+Expedia.shared_secret+Time.now.utc.to_i.to_s)
        else
          raise Expedia::AuthCredentialsError, "cid, api_key and shared_secret are required for Expedia Authentication."
        end
      end

      def common_parameters
        { :cid => Expedia.cid, :sig => signature, :apiKey => Expedia.api_key, :minorRev => Expedia.minor_rev,
          :_type => 'json', :locale => Expedia.locale }
      end

    end

  end
end
