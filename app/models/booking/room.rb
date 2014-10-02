module Booking
  class Room
    include Mongoid::Document

    attr_reader :data

    field :link, type: String

    def description
      self['name']
    end

    def total
      min_price.to_f if min_price
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

    def breakfast?
      self['breakfast_included'].to_i == 1
    end

    def wifi?
      self['free_wifi'].to_i == 1
    end



    # def max_price
    #   other_currency? ? other_currency['price'] : price['price']
    # end


    def commonize(search_criteria)
      {
        provider: :booking,
        description: description,
        price: avg_price(total, search_criteria.total_nights),
        link: link,
        breakfast: breakfast?,
        wifi: wifi?
      }
    end

    # def create_aff_link(city_id, search_criteria)
    #   "http://www.booking.com/searchresults.en-gb.html?city=#{location.city_id}&highlighted_hotels=#{id}&checkin=#{search_criteria.start_date}&checkout=#{search_criteria.end_date}&aid=371919&lang=en-gb&selected_currency=#{search_criteria.currency_code}&label=5e0213fdxf017x9f4bx153cxf42d81aeac1a" 
    # end


    def avg_price(price, nights)
      price / nights
    end
    # private 
    # def method_missing(method, *args, &block)
    #   @data[method.to_s]
    # end

  end

end
