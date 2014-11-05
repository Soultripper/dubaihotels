class HotelResultsController < SearchController

  after_filter :cors_set_access_control_headers

  respond_to :json

  def search       
    return head(400) unless valid_search?
    publish_more_hotels   
    render json: search_results.select(count)       
  end

  def mobile_search       
    return head(400) unless valid_search?   

    _filters = filters
    _filters[:min_price] = nil if hotel_search.state==:new_search
    render json: hotel_search.results.sort(sort).filter(_filters).select_for_mobile(count) 
    # rescue => msg
    #   Log.error "HotelResultsController::mobile_search. error=#{msg}, params=#{params}"
    #   head 500     
  end

  def map_search
    location.hotel_limit = 150
    render json: search_results.select_map_view(count)  
  end

  def hotel_rooms
    render(json:{}) unless cached_search

    if cached_search.is_a?(HotelSearch) 
      Log.debug 'HotelRooms using hotel search cache'
      render json: cached_hotel_rooms
    elsif cached_search.is_a?(HotelRoomSearch) and cached_search.hotel.slug == params[:id]
      Log.debug 'HotelRooms using hotel room search cache'
      render json: cached_search.rooms_results
    else
      render json: {}
    end
    
  end
 
  def cached_hotel_rooms
    hotel_comparison = cached_search.current_hotels.find {|h| h.slug == params[:id]}
    hotel_rooms = cached_rooms.find_hotel params[:id]
    hotel_comparison.rooms_merged(hotel_rooms)
  end

  def hotel_details
    render json: HotelView.new(hotel, search_criteria).as_json
  end


  protected

  def hotel
    @hotel ||= Hotel.find_by_slug params[:id]
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

end
