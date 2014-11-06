module Expedia
  class HotelResponse
    include Mongoid::Document

    embeds_many :images, class_name: 'Expedia::Image'

    field :_id, type: Integer, default: ->{ self.hotelId}

    def top_room_rate
      room_rates[0] if room_rates
    end

    def room_rate_details
      self['RoomRateDetailsList']['RoomRateDetails'] if self['RoomRateDetailsList']
    end

    def rooms
      return [] unless room_rate_details
      @rooms ||= if room_list?
        room_rate_details.map {|room| Expedia::Room.new room}
      else
        [Expedia::Room.new(room_rate_details)]
      end
    end

    def ranking
      self['@order']
    end

    def room_list?
      room_rate_details.is_a? Array
    end

    def room_rates
      rooms.map{|r| r.total.to_f}.sort
      # rooms.map{|r| r.average.to_f}.sort
    end

    def expedia_id
      rooms.first.expedia_id if !rooms.empty?
    end
    # def images
    #   return unless self.HotelImages
    #   self.HotelImages['HotelImage']
    # end

    # def commonize(search_criteria)
    #   return nil unless expedia_id
    #   {
    #     provider: :expedia,
    #     provider_id: expedia_id,
    #     room_count: rooms_count,
    #     min_price: avg_price(room_rates[0], search_criteria.total_nights),
    #     max_price: avg_price(room_rates[-1], search_criteria.total_nights),
    #     ranking: ranking,
    #     #link: search_criteria.expedia_link(expedia_id),
    #     rooms: rooms.map{|r| r.commonize(search_criteria)}
    #   }
    # rescue Exception => msg  
    #   Log.error "Hotel #{id} failed to convert for Expedia.co.uk: #{msg}"
    #   nil
    # end

    # def commonize_to_hotels_dot_com(search_criteria)
    #   # return nil if rooms.empty?
    #   {
    #     provider: :hotels,
    #     provider_id: id,
    #     room_count: rooms_count,
    #     min_price: avg_price(room_rates[0], search_criteria.total_nights),
    #     max_price: avg_price(room_rates[-1], search_criteria.total_nights),
    #     #link: search_criteria.hotels_link(id),
    #     rooms: rooms.map{|r| r.commonize_to_hotels_dot_com(search_criteria, id)}
    #   }
    # rescue Exception => msg  
    #   Log.error "Hotel #{id} failed to convert for hotels.com: #{msg}"
    #   nil
    # end

    def avg_price(price, nights)
      price / nights
    end
    
    def provider
      :expedia
    end

    def provider_id
      expedia_id
    end

    def avg_min_price(search_criteria)  
      avg_price(room_rates[0], search_criteria.total_nights)
    end

    def avg_max_price(search_criteria)
      avg_price(room_rates[-1], search_criteria.total_nights)
    end

    def rooms_count
      rooms.count
    end

    private 

    def self.sort_lookup(sort)
      sort_options[sort.to_s.downcase]
    end

    def self.sort_options
      {
        'exact' => 'NO_SORT',
        'popularity' => 'CITY_VALUE',
        'value' => 'OVERALL_VALUE',
        'promo' => 'PROMO', 
        'price' => 'PRICE',
        'price_reverse' => 'PRICE_REVERSE',
        'prive_average' => 'PRIVE_AVERAGE',
        'rating' => 'QUALITY', 
        'rating_reverse' => 'QUALITY_REVERSE',
        'a_z' => 'ALPHA',
        'proximity' => 'PROXIMITY',
        'postal_code' => 'POSTAL_CODE'
      }
    end    

    def method_missing(method, *args, &block)
      self[method.to_s]
    end

  end

end
