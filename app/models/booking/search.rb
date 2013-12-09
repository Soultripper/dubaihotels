class Booking::Search

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {}

  DEFAULT_SLICE = 600

  CACHE_OPTIONS = {
    expires_in: 4.hours,
    force: true
  }

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end

  def self.by_location(location,search_criteria,params={})
    new(search_criteria).by_location(location, params)
  end

  def by_location(location, options={})        
    params = search_params.merge(options).merge({latitude: location.latitude, longitude: location.longitude, radius: 20})   
    create_response Booking::Client.get_hotel_availability(params), options[:chunk]
  end 

  protected

  def create_response(booking_response, page_no=0)
    Booking::HotelListResponse.new(booking_response, page_no)
  end

  def search_params
    @params = DEFAULT_PARAMS
    @params.merge!({available_rooms: search_criteria.no_of_rooms, guest_qty: search_criteria.no_of_adults})
    add_currency_code
    add_children
    # add_stars
    add_dates
    # add_price_range
  end

  def add_price_range
    @params.merge!(min_stay_price: 30 * search_criteria.total_nights)
  end

  def add_currency_code
    @params.merge!(currency_code: search_criteria.currency_code)
  end

  def add_children
    return unless search_criteria.children?
    @params.merge!({children_qty: search_criteria.children.count, children_age: search_criteria.children.join(',')}) 
  end

  # def add_stars
  #   return if search_criteria.all_stars? 
  #   @params.merge!({           
  #     classes:  [search_criteria.min_stars, search_criteria.max_stars]
  #   })
  # end

  def add_dates
    @params.merge!({ 
      arrival_date:    search_criteria.start_date.to_date.strftime('%Y-%m-%d'),
      departure_date:  search_criteria.end_date.to_date.strftime('%Y-%m-%d')
    })      
  end

end
