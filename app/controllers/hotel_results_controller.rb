class HotelResultsController < SearchController

  before_filter :publish_more_hotels, only: :index
  after_filter :cors_set_access_control_headers

  respond_to :json

  def search       

    if !search_criteria.valid? or !location
      head 400
      return
    end

    publish_more_hotels
    @results = hotel_search.results.sort(sort).filter(filters).select(count)        
    render json: @results
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


  def cached_search
    @cached_search ||= HotelSearch.find params[:key]
  end

  def hotel_search
    @hotel_search ||= HotelSearch.find_or_create(location, search_criteria).start
  end

  def locations
    respond_with Location.autocomplete(query).sort_by {|l| l[:s].length}.take(10)
  end

  protected

  def hotel
    @hotel ||= Hotel.find_by_slug params[:id]
  end

  def publish_more_hotels
    Analytics.more_hotels(publish_options.merge(count: count)) if load_more?
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end


end
