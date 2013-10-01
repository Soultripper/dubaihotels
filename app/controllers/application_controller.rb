class ApplicationController < ActionController::Base
  protect_from_forgery


  protected  
  def room_search
    @search = RoomSearch.new start_date, end_date, {min_stars: min_stars, max_stars: max_stars}
  end

  def min_stars
    params['min_stars'] || 1
  end

  def max_stars
    params['max_stars'] || 5
  end

  def start_date
    (params["start_date"] ? Date.parse(params["start_date"]) : 1.week.from_now).to_date
  end

  def end_date
    (params["end_date"] ? Date.parse(params["end_date"]) : 2.weeks.from_now).to_date
  end
end
