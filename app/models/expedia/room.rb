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
      data['roomTypeDescription']
    end

    def chargeable_rates
      data['RateInfos']['RateInfo']['ChargeableRateInfo']
    end

    def total
      chargeable_rates['@total'].to_f
    end

    def average
      chargeable_rates['@averageRate']
    end

    def commonize(search_criteria)
      {
        provider: 'expedia',
        description: description,
        price: avg_price(total, search_criteria.total_nights)
      }
    end
    
    def avg_price(price, nights)
      price / nights
    end


    private 
    def method_missing(method, *args, &block)
      @data[method.to_s]
    end

  end

end
