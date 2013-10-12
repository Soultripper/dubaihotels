class Expedia::Client 
  class << self 

    def api
      api = Expedia::Api.new
    end

    def page_size
      20
    end

    def get_list(response_name, params, cache_options={expires_in: 4.hours})  
      # response = Rails.cache.fetch Digest::MD5.hexdigest(params.to_s), cache_options do
        Log.info "Expedia get_list request: response_name=#{response_name}, params=#{params}"       
      response = api.get_list(params) 
      # end  

      Log.error "Unable to make request: #{response}"   if !response or response.exception?  
      response 
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

    def destination_room_availability(destination, search_criteria, sort=nil)      
      cache_key = "#{__method__}_#{destination.parameterize}_#{search_criteria.to_s}_#{Expedia.currency_code}_#{sort}_min_stars#{search_criteria.min_stars}"
      fetch(cache_key, 4.hours) do
        Log.info "Checking availability for '#{destination}' for search_criteria: #{search_criteria.to_hash}, cached to #{cache_key}"   
        params = rooms_params_from_search search_criteria, {destinationString: destination, maxRatePlanCount: 30}        
        hotel_list params, sort
      end
    end


    def hotels_availability(hotel_ids, search_criteria, sort=nil)      
      cache_key = "#{__method__}_#{hotel_ids}_#{search_criteria.to_s}_#{Expedia.currency_code}_#{sort}"
      fetch do
        # Log.info "Checking availability for  hotels '#{hotel_ids}' for search_criteria: #{search_criteria.to_hash}, cached to #{cache_key}"   
        params = rooms_params_from_search search_criteria, {hotelIdList: hotel_ids}        
        hotel_list params, sort
      end
    end

    def hotel_room_availability(hotel_id, search_criteria)      
      cache_key = "#{__method__}_#{hotel_id}_#{search_criteria.to_s}_#{Expedia.currency_code}"
      fetch(cache_key, 4.hours) do
        params = rooms_params_from_search search_criteria, {hotelId: hotel_id}
        Log.info "Checking hotel rooom availability for hotel id '#{hotel_id}' for search_criteria: #{search_criteria.to_hash}, cached to #{cache_key}"        
        response = api.get_availability(params)
        rooms = response.body['HotelRoomAvailabilityResponse']['HotelRoomResponse']
        rooms.is_a?(Array) ? rooms : [rooms]
      end
    end

    def fetch(cache_key=nil, cache_expiry=4.hours, &block)
      return unless block_given?
      return yield if !cache_key
      Rails.cache.fetch cache_key, expires_in: cache_expiry  do
        yield
      end
    end


    def search_hotels(destination, search_criteria, sort=nil, overrides={})      
      cache_key = "#{__method__}_#{destination.parameterize}_#{search_criteria.to_s}_#{Expedia.currency_code}_#{sort}_min_stars#{search_criteria.min_stars}"
      fetch(cache_key, 4.hours) do
        Log.info "Checking availability for '#{destination}' for search_criteria: #{search_criteria.to_hash}, cached to #{cache_key}"   
        params = rooms_params_from_search search_criteria, {destinationString: destination, maxRatePlanCount: 30}        
        make_request('HotelListResponse', params.merge({sort: sort, numberOfResults: page_size}).merge(overrides)) {|q_params| api.get_list q_params }
        # Expedia::Response.new(sort ? api.get_list() : api.get_list(params))
      end
    end

    protected

    def rooms_params_from_search(search_criteria, params={})
      room_group = search_criteria.no_of_adults.to_s
      room_group += "#{search_criteria.children.join(',')}" if search_criteria.children?

      add_stars(search_criteria, params)
      add_dates(search_criteria, params)

      params.merge({ "room#{search_criteria.no_of_rooms}"=> room_group, options: 'ROOM_RATE_DETAILS' })
    end

    def make_request(response_name, query_params, &block)
      response = yield query_params if block_given?
      Expedia::Response.new(response.body[response_name])
    end

    def hotel_list(params, sort=nil)
      response = sort ? api.get_list(params.merge({sort: sort, numberOfResults: page_size})) : api.get_list(params)
      hotels = response.body['HotelListResponse']['HotelList']['HotelSummary']
      hotels.is_a?(Array) ? hotels : [hotels]
    end

    def add_stars(search_criteria, params)
      return if search_criteria.all_stars? 
      params.merge!({           
        minStarRating:  search_criteria.min_stars,
        maxStarRating:  search_criteria.max_stars
      })
    end

    def add_dates(search_criteria, params)
      params.merge!({ 
        arrivalDate:    search_criteria.start_date.to_date.strftime('%m/%d/%Y'),
        departureDate:  search_criteria.end_date.to_date.strftime('%m/%d/%Y')
      })      
    end

  end
end
