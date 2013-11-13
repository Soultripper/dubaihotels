class SearchController < ApplicationController

  before_filter {Expedia.currency_code = currency}

  respond_to :json

  def index        


    # respond_with @hotel_search

    respond_to do |format|
      format.json do 
        results = HotelSearch.find_or_create(location, search_criteria).start.results
        @hotel_search = results.sort(sort).filter(filters).paginate(page_no, page_size)        
        render json: @hotel_search
      end
      format.html
    end

  end

  def locations
    respond_with Location.autocomplete(query).sort_by {|l| l[:s].length}.take(10)
  end

  protected

  def location
    @location ||= Location.find_by_slug slug
  end

  def slug
    @slug ||= params[:id]
  end

  def query
    @query ||= params[:query]
  end

  helper_method :location
end
