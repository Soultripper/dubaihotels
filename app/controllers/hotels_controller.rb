class HotelsController < ApplicationController

  respond_to :json

  def index
    respond_with HotelSearch.new(destination, search_criteria).start(paging).hotels
  end

  def show
    @rooms = Expedia::Hotel.check_room_availability(hotel.ean_hotel_id, search_criteria)
    respond_with @rooms, layout: nil
  end

  protected

  def hotel
    @hotel ||= Hotel.find params[:id]
  end

  helper_method :hotel
end
