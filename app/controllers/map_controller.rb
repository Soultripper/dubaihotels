class MapController < ApplicationController

  respond_to :json


  def index        

    respond_to do |format|
      format.json do 
        @results = hotel_search.results.sort(sort).filter(filters).take(page_no, page_size)   
        render json: @results
      end
    end

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
  end

  def slug
    @slug ||= (params[:id] || params[:hotel])
  end

  def coordinates
    @coordinates ||= params[:coordinates].split(',') if params[:coordinates]
  end

  helper_method :location
end
