module Expedia
  class Response

    attr_reader :name, :data

    def initialize(name, data)
      @name, @data = name, data[name]
      if error?
        Log.error "Expedia Response Invalid: #{data}"
        raise "Expedia Response Invalid: #{error_message}"
      end
    end

    def error?
      data['EanWsError']
    end

    def error_message
      data['EanWsError']['verboseMessage']
    end

    def more_pages?
      moreResultsAvailable
    end

    def next_page
      return unless more_pages?
      Expedia::Client.get_list(next_params)
    end

    def cache_details
      self.cachedSupplierResponse
    end
    
    def next_params
      {
        cacheKey: self.cacheKey,
        cacheLocation: self.cacheLocation
      }
    end

    protected 
    def method_missing(method, *args, &block)
      data[method.to_s]
    end

  end

end
