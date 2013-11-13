class Expedia::Client 
  class << self 

    def api
      api = Expedia::Api.new
    end

    def url
      "http://api.ean.com"
    end

    def http
      Faraday.new(url: url) do |faraday|
        faraday.headers['Accept-Encoding'] = 'gzip,deflate'
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.response :gzip 
        faraday.adapter  :typhoeus
      end
    end

    def get_list(params, &block)  
      params.merge!(credentials)
      create_response http.get('/ean-services/rs/hotel/v3/list', params), &block
    end

    def get_availability( params, &block)    
      params.merge!(credentials)  
      create_response http.get('/ean-services/rs/hotel/v3/avail', params), &block
    end

    def create_response(response, &block)
      response = Expedia::HTTPService.create_response(response)
      if !response or response.exception?  
        Log.error "Unable to make request: #{response}"   
        nil
      else
        block_given? ? yield(response) : response
      end     
    end

    def credentials
      { 
        cid: Expedia.cid, 
        sig: signature, 
        apiKey: Expedia.api_key, 
        minorRev: Expedia.minor_rev,
        _type:'json', 
        locale:Expedia.locale 
      }
    end

    def signature
      if Expedia.cid && Expedia.api_key && Expedia.shared_secret
        Digest::MD5.hexdigest(Expedia.api_key+Expedia.shared_secret+Time.now.utc.to_i.to_s)
      else
        raise Expedia::AuthCredentialsError, "cid, api_key and shared_secret are required for Expedia Authentication."
      end
    end

    # def hotel(id, options=nil)
    #   response = api.get_information({hotelId: id})
    #   response.body['HotelInformationResponse']
    # end

    # def hotels_by_ids(ids, sort=nil)
    #   Log.info "Fetching hotels by ids: '#{ids}'"
    #   hotel_list({ hotelIdList: ids}, sort)
    # end

    # def hotels_by_destination(destination, sort=nil)
    #   cache_key = "#{__method__}_#{destination.parameterize}_#{Expedia.currency_code}_#{sort}"
    #   Log.info "Fetching hotels by destination '#{destination}', cached to #{cache_key}"
    #   hotel_list({ destinationString: destination}, sort)
    # end

    # def destination_room_availability(destination, search_criteria, sort=nil)      
    #   cache_key = "#{__method__}_#{destination.parameterize}_#{search_criteria.to_s}_#{Expedia.currency_code}_#{sort}_min_stars#{search_criteria.min_stars}"
    #   Log.info "Checking availability for '#{destination}' for search_criteria: #{search_criteria.to_hash}, cached to #{cache_key}"   
    #   params = rooms_params_from_search search_criteria, {destinationString: destination, maxRatePlanCount: 30}        
    #   hotel_list params, sort
    # end

    # def hotels_availability(hotel_ids, search_criteria, sort=nil)      
    #   cache_key = "#{__method__}_#{hotel_ids}_#{search_criteria.to_s}_#{Expedia.currency_code}_#{sort}"
    #   params = rooms_params_from_search search_criteria, {hotelIdList: hotel_ids}        
    #   hotel_list params, sort
    # end


    # def search_hotels(destination, search_criteria, sort=nil, overrides={})      
    #   cache_key = "#{__method__}_#{destination.parameterize}_#{search_criteria.to_s}_#{Expedia.currency_code}_#{sort}_min_stars#{search_criteria.min_stars}"
    #   Log.info "Checking availability for '#{destination}' for search_criteria: #{search_criteria.to_hash}, cached to #{cache_key}"   
    #   params = rooms_params_from_search search_criteria, {destinationString: destination, maxRatePlanCount: 30}        
    #   make_request('HotelListResponse', params.merge({sort: sort, numberOfResults: page_size}).merge(overrides)) {|q_params| api.get_list q_params }
    # end

    # protected

    # def rooms_params_from_search(search_criteria, params={})
    #   room_group = search_criteria.no_of_adults.to_s
    #   room_group += "#{search_criteria.children.join(',')}" if search_criteria.children?

    #   add_stars(search_criteria, params)
    #   add_dates(search_criteria, params)

    #   params.merge({ "room#{search_criteria.no_of_rooms}"=> room_group, options: 'ROOM_RATE_DETAILS' })
    # end

    # def make_request(response_name, query_params, &block)
    #   response = yield query_params if block_given?
    #   Expedia::Response.new(response.body[response_name])
    # end

    # def hotel_list(params, sort=nil)
    #   response = sort ? api.get_list(params.merge({sort: sort, numberOfResults: page_size})) : api.get_list(params)
    #   hotels = response.body['HotelListResponse']['HotelList']['HotelSummary']
    #   hotels.is_a?(Array) ? hotels : [hotels]
    # end

    # def add_stars(search_criteria, params)
    #   return if search_criteria.all_stars? 
    #   params.merge!({           
    #     minStarRating:  search_criteria.min_stars,
    #     maxStarRating:  search_criteria.max_stars
    #   })
    # end

    # def add_dates(search_criteria, params)
    #   params.merge!({ 
    #     arrivalDate:    search_criteria.start_date.to_date.strftime('%m/%d/%Y'),
    #     departureDate:  search_criteria.end_date.to_date.strftime('%m/%d/%Y')
    #   })      
    # end

  end
end
