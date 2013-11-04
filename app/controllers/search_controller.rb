class SearchController < ApplicationController

  before_filter {Expedia.currency_code = currency}

  respond_to :json, :html

  def index        
    results = HotelSearch.find_or_create(location, search_criteria).start.results
    @hotel_search = results.sort(sort).paginate(page_no, page_size)
    respond_with @hotel_search
  end

  protected

  def location
    @location ||= Location.find_by_slug slug
  end

  def slug
    @slug ||= params[:id]
  end

  helper_method :location
end
