class SearchController < ApplicationController

  before_filter {Expedia.currency_code = currency}

  respond_to :json, :html

  def index    
    # ratings = Expedia::Hotel.with_ratings([5])
    # @hotels = Expedia::Hotel.available_for_ids ratings, search_criteria, sort
    results = HotelSearch.find_or_create(destination, search_criteria).start.results
    @hotel_search = results.sort(sort.to_sym).paginate(page_no, page_size)

    respond_with @hotel_search
    # @hotels = Expedia::Hotel.available(destination, search_criteria, sort)
  end



  protected


end
