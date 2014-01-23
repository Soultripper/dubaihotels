class HotelsController < ApplicationController

  before_filter :validate_search

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
    @hotel ||= Hotel.find params[:id]
  end

  def validate_search
    search_criteria.valid?
  end

  helper_method :hotel, :hotel_view
end
