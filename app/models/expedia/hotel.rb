module Expedia
  class Hotel
    include Mongoid::Document
    include Mongoid::Timestamps

    embeds_many :images, class_name: 'Expedia::Image'

    field :_id, type: Integer, default: ->{ self.hotelId}

    def self.create_from_csv(row)
      fields = row.to_hash
      fields['hotelId'] = fields.first[1]
      with(safe:false).create(fields)
    end

   def self.check_room_availability(id, room_search)
      Client.hotel_room_availability(id, room_search).map {|r| Room.new r}
    end

    # def self.find_or_fetch(id)  
    #   find(id) || fetch(id)
    # end

    # def self.fetch(id)  
    #   with(safe:false).create(Client.hotel(id))
    # end

    def self.find_by_ids(ids, sort=:popularity)
      Client.hotels_by_ids(ids.join(','), sort_lookup(sort)).map {|hotel| new hotel}
    end

    def self.find_in(destination, sort=:popularity)
      Client.hotels_by_destination(destination, sort_lookup(sort)).map {|hotel| new hotel}
    end

    def self.available(destination, room_search, sort=:popularity)
      Client.destination_room_availability(destination, room_search, sort_lookup(sort)).map {|hotel| new hotel}
    end

    def self.available_for_ids(hotel_ids, room_search, sort=:popularity)
      Client.hotels_availability(hotel_ids.join(','), room_search, sort_lookup(sort)).map {|hotel| new hotel}
    end

    def self.with_ratings(stars)
      self.in({'HotelSummary.hotelRating'=> stars}).map &:_id
    end

    # def id
    #   self.HotelSummary['hotelId'] if self.HotelSummary
    # end

    def check_room_availability(room_search)
      Hotel.check_room_availability(id, room_search).map {|r| Room.new r}
    end

    # def name
    #   self.HotelSummary['name']
    # end

    def total
      charge_info['@total'] if charge_info
    end

    def currency
      charge_info['@currencyCode'] if charge_info
    end

    def charge_info
      rate_info['ChargeableRateInfo'] if rate_info
    end

    def rate_info
      top_room_rate['RateInfos']['RateInfo'] if top_room_rate
    end

    def top_room_rate
      room_rate_details[0] if room_rate_details
    end

    def room_rate_details
      self['RoomRateDetailsList']['RoomRateDetails'] if self['RoomRateDetailsList']
    end

    def rooms_count
      room_rate_details.count if room_rate_details
    end

    # def images
    #   return unless self.HotelImages
    #   self.HotelImages['HotelImage']
    # end

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
