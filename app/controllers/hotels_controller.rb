class HotelsController < ApplicationController

  respond_to :html

  def show
    @rooms = Expedia::Hotel.check_room_availability(hotel.ean_hotel_id, room_search)
    respond_with @rooms, layout: nil
  end

  protected

  def hotel
    @hotel ||= Hotel.find params[:id]
  end

  helper_method :hotel
end
