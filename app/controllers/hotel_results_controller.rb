class HotelResultsController < SearchController

  after_filter :cors_set_access_control_headers

  respond_to :json

  def search       
    return head(400) unless valid_search?
    publish_more_hotels   
    render json: search_results.select(count)       
  end

  def map_search
    location.hotel_limit = 150
    render json: search_results.select_map_view(count)  
  end

  def hotel_rooms
    render(json:{}) unless cached_search

    if cached_search.is_a?(HotelSearch) and hotel_comparison = cached_search.hotels.find {|h| h.slug== params[:id]}
      render json: hotel_comparison.rooms
    elsif cached_search.is_a?(HotelRoomSearch) and cached_search.hotel.slug == params[:id]
      render json: cached_search.rooms_results
    else
      render json: {}
    end
    
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
