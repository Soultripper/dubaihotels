class MapController < ApplicationController

  respond_to :json


  HOTEL_LIMIT = 300

  def index        

    # respond_to do |format|
      # format.json do 
        @results = hotel_search.results.sort(sort).filter(filters).select_map_view(count)   
        render json: @results
      # end
    # end

  end

  protected

  def hotel_search
    @hotel_search ||= HotelSearch.find_or_create(location, search_criteria).start
  end

  def location
    if coordinates
      @location = Location.my_location *coordinates
    else
      @location ||= Location.find_by_slug slug
    end

    @location.hotel_limit = HOTEL_LIMIT
    @location
  end

  def slug
    @slug ||= (params[:id] || params[:hotel])
  end

  def coordinates
    @coordinates ||= params[:coordinates].split(',') if params[:coordinates]
  end

  helper_method :location
end
