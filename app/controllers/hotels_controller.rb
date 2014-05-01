class HotelsController < ApplicationController

  before_filter :validate_search, :publish_hotel_seo

  respond_to :json, :html

  layout 'hotel'

  def index
    respond_with HotelSearch.new(destination, search_criteria).start(paging).hotels
  end

  def show
    respond_with hotel_view
  end

  def rooms
    @rooms = hotel_room_search.results
    respond_with @rooms, layout: nil
  end

  protected

  def publish_hotel_seo
    options = {
      search_criteria: search_criteria.as_json.merge(sort: sort),
      hotel: hotel,
      request_params: request_params
    }
    Analytics.hotel_seo options
  end

  def hotel_view
    @hotel_view ||= HotelView.new(hotel, search_criteria).as_json
  end

  def hotel_room_search
    @hotel_room_search ||= HotelRoomSearch.find_or_create(hotel_id, search_criteria).start
  end

  def hotel_id
    params[:id].to_i
  end

  def hotel
    @hotel ||= Hotel.find_by_slug params[:id]
  end

  def validate_search
    search_criteria.valid?
  end

  helper_method :hotel, :hotel_view
end
