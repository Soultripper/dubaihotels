module Booking
  class Room
    include Mongoid::Document

    attr_reader :data

    def description
      self['name']
    end

    def total
      min_price.to_f
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


    def commonize(search_criteria)
      {
        provider: 'booking',
        description: description,
        price: avg_price(total, search_criteria.total_nights)
      }
    end
    

    def avg_price(price, nights)
      price / nights
    end
    # private 
    # def method_missing(method, *args, &block)
    #   @data[method.to_s]
    # end

  end

end
