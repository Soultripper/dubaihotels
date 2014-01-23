class ApplicationController < ActionController::Base
  protect_from_forgery


  protected  

  def user_channel
    @user_channel = session['session_id']
  end
  
  def search_criteria
    @search = SearchCriteria.new start_date, end_date, {star_ratings: star_ratings, currency_code: currency, sort: sort, min_price: min_price, max_price: max_price}
  end

  def min_price
    @min_price = Utilities.nil_round(params['min_price'])
    @min_price < 30 ? 30 : @min_price
  end

  def max_price
    params['max_price'] unless params['max_price'].blank?
  end

  def start_date
    (!params["start_date"].blank? ? Date.parse(params["start_date"]) : 20.days.from_now).to_date
  end

  def end_date
    (!params["end_date"].blank?  ? Date.parse(params["end_date"]) : 3.weeks.from_now).to_date
  end

  def page_no
    (params[:page_no] || 1).to_i
  end

  def page_size
    (params[:page_size] || HotelsConfig.page_size).to_i
  end

  def amenities
    params[:amenities].split(',') unless params[:amenities].blank? 
  end

  def star_ratings
    params[:star_ratings].split(',') unless params[:star_ratings].blank? 
  end

  def filters
    {
      min_price:    min_price,
      max_price:    max_price,
      star_ratings: star_ratings,
      amenities:    amenities
    }
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
     (!params["currency"].blank?) ? params["currency"] : "GBP"
  end

  def sort
    params["sort"] || :recommended
  end

  helper_method :currency, :sort, :start_date, :end_date, :min_stars, :max_stars, :destination, :user_channel

end
