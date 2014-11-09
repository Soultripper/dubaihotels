class HotelsController < ApplicationController

  before_filter :validate_search 

  respond_to :json, :html

  layout 'hotel'

  def index
    respond_with HotelSearch.new(destination, search_criteria).start(paging).hotels
  end

  def show
    publish_hotel_seo
    
    respond_with hotel_view
  end

  def mobile_show
    publish_hotel_seo
    _rooms = cached_hotel_rooms
    
    unless _rooms and !_rooms.empty?
      _rooms = hotel_room_search.rooms_results
    end
    # room_search=hotel_room_search
    # key = hotel_room_search.cache_key unless rooms

    mobile_hotel_view ||= HotelView.new(hotel, search_criteria).as_json rooms: _rooms, key: params[:key], include_providers:true
    respond_with mobile_hotel_view
  end

  protected

  def hotel_view
    key = hotel_room_search.cache_key unless rooms

    @hotel_view ||= HotelView.new(hotel, search_criteria).as_json rooms: rooms, key: key
  end

  def hotel
    @hotel ||=  Hotel.find_by_slug(params[:id])
  end

  def publish_hotel_seo
    options = {
      search_criteria: search_criteria.as_json.merge(sort: sort),
      hotel: hotel.to_analytics,
      request_params: request_params
    }
    HotelScorer.score(hotel, :hotel_seo) if Analytics.hotel_seo(options) 
  end

  def cached_search
    @cached_search ||= HotelSearch.find params[:key]
  end

  def cached_rooms
    @cached_rooms ||= RoomsCache.find_or_create_from_cache params[:key]
  end

  def hotel_room_search
    @hotel_room_search ||= HotelRoomSearch.find_or_create(hotel, search_criteria).start
  end

  def rooms
    if cached_search #and @hotel_comparison = cached_search.hotels.find {|h| h.slug == params[:id]}
      cached_hotel_rooms
      #@hotel_comparison.rooms
    end
  end

  def cached_hotel_rooms
    return unless cached_search and cached_search.hotels
    hotel_comparison = cached_search.hotels.find {|h| h.slug == params[:id]}
    Log.debug "Found cached search" if hotel_comparison
    hotel_comparison.rooms if hotel_comparison
    # hotel_rooms = cached_rooms.find_hotel params[:id]
    # throw hotel_rooms
    # hotel_comparison.rooms_merged(hotel_rooms)
  end


  def hotel_id
    params[:id].to_i
  end


  def validate_search
    search_criteria.valid?
  end

  helper_method :hotel, :hotel_view
end
