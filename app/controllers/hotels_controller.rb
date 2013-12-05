class HotelsController < ApplicationController

  respond_to :json

  def index
    respond_with HotelSearch.new(destination, search_criteria).start(paging).hotels
  end

  def show
    @rooms = hotel_room_search.results
    respond_with @rooms, layout: nil
  end

  protected

  def hotel_room_search
    @hotel_room_search ||= HotelRoomSearch.find_or_create(hotel_id, search_criteria).start
  end

  def hotel_id
    params[:id].to_i
  end

  def hotel
    @hotel ||= Hotel.find params[:id]
  end

  helper_method :hotel
end
