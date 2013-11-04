module Booking
  class Room
    include Mongoid::Document

    attr_reader :data

    def description
      self['name']
    end

    def total
      min_price
    end

    def price
      self[:min_price]
    end

    def currency
      other_currency? ? other_currency['currency'] : price['currency']
    end

    def other_currency?
      other_currency
    end

    def other_currency
      price['other_currency']
    end

    def min_price
      other_currency? ? other_currency['price'] : price['price']
    end 

    # def max_price
    #   other_currency? ? other_currency['price'] : price['price']
    # end


    def commonize
      {
        provider: 'booking',
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
