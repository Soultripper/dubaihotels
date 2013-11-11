require 'faraday'
require 'expedia/http_service/response'

module Expedia
  module HTTPService

    API_SERVER = 'api.ean.com'
    RESERVATION_SERVER = 'book.api.ean.com'

    class << self

      def server(options = {})
        server = "#{options[:reservation_api] ? RESERVATION_SERVER : API_SERVER}"
        "#{options[:use_ssl] ? "https" : "http"}://#{server}"
      end


      def make_request(path, args, verb, options = {})
        args.merge!(add_common_parameters)
        # figure out our options for this request
        request_options = {:params => (verb == :get ? args : {})}
        # set up our Faraday connection
        conn = Faraday.new(server(options), request_options)
        conn.headers['Accept-Encoding'] = 'gzip,deflate'
        conn.response :gzip 
        response = conn.send(verb, path, (verb == :post ? args : {}))

        Expedia::Utils.debug "\nExpedia [#{verb.upcase}] - #{server(options) + path} params: #{args.inspect} : #{response.status}\n"
        response = Expedia::HTTPService::Response.new(response.status.to_i, response.body, response.headers)

        # If there is an exception make a [Expedia::APIError] object to return
        if response.exception?
          Expedia::APIError.new(response.status, response.body)
        else
          response
        end
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

      def add_common_parameters
        { :cid => Expedia.cid, :sig => signature, :apiKey => Expedia.api_key, :minorRev => Expedia.minor_rev,
          :_type => 'json', :locale => Expedia.locale }
      end

    end

  end
end
