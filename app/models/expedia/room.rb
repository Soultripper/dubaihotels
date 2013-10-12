module Expedia
  class Room

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def self.find_in(destination)
      Client.hotels_in(destination).map {|h| new h}
    end

    def description
      data['roomDescription']
    end

    def chargeable_rates
      data['RateInfos']['RateInfo']['ChargeableRateInfo']
    end

    def total
      chargeable_rates['@total']
    end

    def commonize
      {
        description: description,
        price: total
      }
    end
    
    private 
    def method_missing(method, *args, &block)
      @data[method.to_s]
    end

  end

end
