class SearchController < ApplicationController

  def index
    Expedia.currency_code = currency
    ratings = Expedia::Hotel.with_ratings([5])
    @hotels = Expedia::Hotel.available_for_ids ratings, room_search, sort
    # @hotels = Expedia::Hotel.available destination, room_search, sort
  end

  protected

  def room_search
    @search = RoomSearch.new start_date, end_date
  end

  def start_date
    (params["start_date"] ? Date.parse(params["start_date"]) : 1.week.from_now).to_date
  end

  def end_date
    (params["end_date"] ? Date.parse(params["end_date"]) : 2.weeks.from_now).to_date
  end

  def destination
    params["destination"] || "dubai"
  end

  def currency
    params["currency"] || "GBP"
  end

  def sort
    params["sort"] || :popularity
  end

  helper_method :currency, :sort, :start_date, :end_date

end
