class SearchController < ApplicationController

  before_filter {Expedia.currency_code = currency}

  respond_to :json, :html

  def index    
    # results = HotelSearch.find_or_create(destination, search_criteria).start.results
    # @hotel_search = results.sort(sort.to_sym).paginate(page_no, page_size)

    # respond_with @hotel_search
  end



  protected


end
