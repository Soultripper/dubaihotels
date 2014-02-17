class SearchController < ApplicationController

  before_filter :validate_search

  respond_to :json

  layout 'search'

  def index        

    # respond_with @hotel_search

    if !search_criteria.valid?
      head 400
      return
    end

    respond_to do |format|
      format.json do 
        @results = hotel_search.results.sort(sort).filter(filters).paginate(page_no, page_size)        
        render json: @results

      end
      format.html do
        @results = hotel_search.results.sort(sort).paginate(1, page_size)        
        @user_channel = hotel_search.channel
      end
    end

  end

  def hotel_search
    @hotel_search ||= HotelSearch.find_or_create(location, search_criteria).start
  end

  def locations
    respond_with Location.autocomplete(query).sort_by {|l| l[:s].length}.take(10)
  end

  protected

  def validate_search
    search_criteria.valid?
  end

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
