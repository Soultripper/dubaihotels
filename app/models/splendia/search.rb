class Splendia::Search < ProviderHotelSearch

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {targeted_market:'united-kingdom', lang:'EN'}

  def create_list_response(xml)
    Splendia::HotelListResponse.new(xml)
  end


  def create_hotels_list(response_body)
    xml = Nokogiri.XML(response_body)
    hotels_list = create_list_response xml
    xml = nil
    hotels_list
  end

  protected

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
