class ApplicationController < ActionController::Base
  protect_from_forgery

  MIN_PRICE = 25
  START_DATE = Date.tomorrow
  END_DATE = 2.days.from_now
  CURRENCY_CODE = 'GBP'
  
  protected  

  def user_agent
    @user_agent ||= UserAgent.parse(request.user_agent)
  end

  def request_params
    {
      server_time: Time.now,
      host: request.headers['HTTP_HOST'],
      remote_ip: request.remote_ip,
      browser: user_agent.browser,
      platform: user_agent.platform,
      browser_version: user_agent.version.to_s,
      os: user_agent.os, 
      is_mobile: user_agent.mobile?,
      referrer: request.referrer,
      uuid: request.uuid,
      location: geo_location.data.as_json
    }
  end

  def geo_location
    @geo_location ||= request.location
  end

  def user_channel
    @user_channel = session['session_id']
  end
  
  def search_criteria
    @search = SearchCriteria.new start_date, end_date, {star_ratings: star_ratings, currency_code: currency, sort: sort, min_price: min_price, max_price: max_price}
  end

  def min_price
    @min_price = Utilities.nil_round(params['min_price'])
    @min_price < MIN_PRICE ? MIN_PRICE : @min_price
  end

  def max_price
    params['max_price'] unless params['max_price'].blank?
  end

  def start_date
    return Date.today if params[:msitewrapper].to_i == 1
    (!params["start_date"].blank? ? Date.parse(params["start_date"]) : START_DATE).to_date
  end

  def end_date
    return Date.tomorrow if params[:msitewrapper].to_i == 1
    (!params["end_date"].blank?  ? Date.parse(params["end_date"]) : END_DATE).to_date
  end

  def count
    (params[:count] || HotelsConfig.page_size).to_i
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
     (!params["currency"].blank?) ? params["currency"] : find_currency_code
   rescue => msg
    Log.error "Unable to locate country code, msg: #{msg}"
    CURRENCY_CODE
  end

  # def currency
  #    (!params["currency"].blank?) ? params["currency"] : CURRENCY_CODE
  # end


  def find_currency_code
    currency_code = Currency.codes[user_location_code.to_sym] || Currency.codes.first[1]
    currency_code[0]
  end

  def user_location_code
    @user_country_code ||= request.location.country_code.upcase
  end

  def sort
    params["sort"] || :recommended
  end

  helper_method :currency, :sort, :start_date, :end_date, :min_stars, :max_stars, :destination, :user_channel

end
