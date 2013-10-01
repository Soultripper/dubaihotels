class SearchController < ApplicationController

  def index
    Expedia.currency_code = currency
    # ratings = Expedia::Hotel.with_ratings([5])
    # @hotels = Expedia::Hotel.available_for_ids ratings, room_search, sort
    @hotels = Expedia::Hotel.available(destination, room_search, sort)
  end


  protected


  def destination
    params["destination"] || "dubai"
  end

  def currency
    params["currency"] || "GBP"
  end

  def sort
    params["sort"] || :popularity
  end


  helper_method :currency, :sort, :start_date, :end_date, :min_stars, :max_stars

end
