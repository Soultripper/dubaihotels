class HotelsController < ApplicationController

  respond_to :json

  def index
    respond_with HotelSearch.new(destination, search_criteria).start(paging).hotels
  end

  def show
    @rooms = HotelRoomSearch.check_availability(hotel, search_criteria).results
    respond_with @rooms, layout: nil
  end

  protected

  def hotel
    @hotel ||= Hotel.find params[:id]
  end

  helper_method :hotel
end
