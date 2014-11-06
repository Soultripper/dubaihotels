class LateRooms::Search < ProviderHotelSearch

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {
    detailsearch: true,
    atype: true,
    compressed: true 
  }

  def create_list_response(xml)
    LateRooms::HotelListResponse.new(xml)
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
