class ApplicationController < ActionController::Base
  protect_from_forgery


  protected  
  def search_criteria
    @search = SearchCriteria.new start_date, end_date, {min_stars: min_stars, max_stars: max_stars}
  end

  def min_stars
    params['min_stars'] || 1
  end

  def max_stars
    params['max_stars'] || 5
  end

  def start_date
    (!params["start_date"].blank? ? Date.parse(params["start_date"]) : 1.week.from_now).to_date
  end

  def end_date
    (!params["end_date"].blank?  ? Date.parse(params["end_date"]) : 2.weeks.from_now).to_date
  end

  def page_no
    (params[:page_no] || 1).to_i
  end

  def page_size
    (params[:page_size] || HotelsConfig.page_size).to_i
  end

  def paging
    {
      page_size: page_size,
      page_no: page_no,
      page_index: page_size*page_no-1
    }
  end

  def destination
    (params["id"] || "dubai").gsub('-hotels', '').gsub('-',' ')
  end

  def currency
    params["currency"] || "GBP"
  end

  def sort
    params["sort"] || :price
  end

  helper_method :currency, :sort, :start_date, :end_date, :min_stars, :max_stars, :destination

end
