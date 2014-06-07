class Venere::Search

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {numRooms: 1}

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end

  protected

  def create_list_response(response)
    Venere::HotelListResponse.new(response)
  end

  def search_params
    @params = DEFAULT_PARAMS
    @params.merge!({numGuests: search_criteria.no_of_adults, numRooms: search_criteria.no_of_rooms})
    add_country_code
    add_currency_code
    add_dates
  end

  def add_country_code
    @params.merge!(country_code: search_criteria.country_code)
  end

  def add_currency_code
    @params.merge!(currency_code: search_criteria.currency_code)
  end

  def add_dates
    @params.merge!({ 
      start_date: search_criteria.start_date.to_date.strftime('%Y-%m-%d'),
      end_date:   search_criteria.end_date.to_date.strftime('%Y-%m-%d'),
    })      
  end

end
