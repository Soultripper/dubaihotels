class Expedia::Client 
  class << self 

    def api
      api = Expedia::Api.new
    end

    def page_size
      50
    end

    def hotel(id, options=nil)
      fetch do
        response = api.get_information({hotelId: id})
        response.body['HotelInformationResponse']
      end
    end

    def hotels_by_ids(ids, sort=nil)
      fetch do
        Log.info "Fetching hotels by ids: '#{ids}'"
        hotel_list({ hotelIdList: ids}, sort)
      end
    end

    def hotels_by_destination(destination, sort=nil)
      cache_key = "#{__method__}_#{destination.parameterize}_#{Expedia.currency_code}_#{sort}"
      fetch(cache_key, 24.hours) do
        Log.info "Fetching hotels by destination '#{destination}', cached to #{cache_key}"
        hotel_list({ destinationString: destination}, sort)
      end
    end

    def destination_room_availability(destination, room_search, sort=nil)      
      cache_key = "#{__method__}_#{destination.parameterize}_#{room_search.to_s}_#{Expedia.currency_code}_#{sort}"
      fetch(cache_key, 4.hours) do
        Log.info "Checking availability for '#{destination}' for room_search: #{room_search.to_hash}, cached to #{cache_key}"   
        params = rooms_params_from_search room_search, {destinationString: destination}        
        hotel_list params, sort
      end
    end

    def hotels_availability(hotel_ids, room_search, sort=nil)      
      cache_key = "#{__method__}_#{hotel_ids}_#{room_search.to_s}_#{Expedia.currency_code}_#{sort}"
      fetch do
        # Log.info "Checking availability for  hotels '#{hotel_ids}' for room_search: #{room_search.to_hash}, cached to #{cache_key}"   
        params = rooms_params_from_search room_search, {hotelIdList: hotel_ids}        
        hotel_list params, sort
      end
    end

    def hotel_room_availability(hotel_id, room_search)      
      cache_key = "#{__method__}_#{hotel_id}_#{room_search.to_s}_#{Expedia.currency_code}"
      fetch(cache_key, 4.hours) do
        params = rooms_params_from_search room_search, {hotelId: hotel_id}
        Log.info "Checking hotel rooom availability for hotel id '#{hotel_id}' for room_search: #{room_search.to_hash}, cached to #{cache_key}"        
        response = api.get_availability(params)
        response.body['HotelRoomAvailabilityResponse']['HotelRoomResponse']
      end
    end

    def fetch(cache_key=nil, cache_expiry=4.hours, &block)
      return unless block_given?
      return yield if !cache_key
      Rails.cache.fetch cache_key, expires_in: cache_expiry  do
        yield
      end
    end

    protected

    def rooms_params_from_search(room_search, params={})
      room_group = room_search.no_of_adults.to_s
      room_group += "#{room_search.children.join(',')}" if room_search.children?
      params.merge({
        arrivalDate:    room_search.start_date.to_date.strftime('%m/%d/%Y'),
        departureDate:  room_search.end_date.to_date.strftime('%m/%d/%Y'),
        "room#{room_search.no_of_rooms}"=> room_group
      })
    end

    def hotel_list(params, sort=nil)
      response = sort ? api.get_list(params.merge({sort: sort, numberOfResults: page_size})) : api.get_list(params)
      hotels = response.body['HotelListResponse']['HotelList']['HotelSummary']
      hotels.is_a?(Array) ? hotels : [hotels]
    end

  end
end
