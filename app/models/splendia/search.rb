class Splendia::Search

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {targeted_market:'united-kingdom', lang:'EN'}

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end


  protected

  def create_list_response(response)
    Splendia::HotelListResponse.new(response)
  end


  def search_params
    @params = DEFAULT_PARAMS
    @params.merge!({numguests: search_criteria.no_of_adults})
    add_currency_code
    add_dates
  end

  def add_currency_code
    @params.merge!(currency: search_criteria.currency_code)
  end

  def add_dates
    @params.merge!({ 
      arrivaldate:    search_criteria.start_date.to_date.strftime('%Y-%m-%d'),
      returndate:  search_criteria.end_date.to_date.strftime('%Y-%m-%d')
    })      
  end

end
