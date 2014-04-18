class LateRooms::Search

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {}

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end


  protected

  def create_list_response(response)
    LateRooms::HotelListResponse.new(response)
  end


  def search_params
    @params = DEFAULT_PARAMS
    # @params.merge!({adults: search_criteria.no_of_adults})
    add_currency_code
    add_dates
  end

  def add_currency_code
    @params.merge!(cur: search_criteria.currency_code)
  end

  def add_dates
    @params.merge!({ 
      sdate:    search_criteria.start_date.to_date.strftime('%Y-%m-%d'),
      nights:  search_criteria.total_nights
    })      
  end

end
