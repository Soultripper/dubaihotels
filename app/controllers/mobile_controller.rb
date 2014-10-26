class MobileController < ApplicationController

  before_filter :publish_search, only: :index
  respond_to :json


  def index        
    render json: hotel_search.results.select_for_mobile(count)     
  end


  protected

  def hotel_search
    @hotel_search ||= HotelSearch.find_or_create(location, search_criteria).start
  end


  def location
    if coordinates
      @location ||= Location.my_location *coordinates
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

  def publish_search
    Analytics.search publish_options
  end

  def publish_options
    {
      search_criteria: search_criteria.as_json.merge(sort: sort),
      location: location.as_json,
      request_params: request_params
    }
  end


  helper_method :location, :search_criteria
end
