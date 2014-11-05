class Agoda::Search < ProviderHotelSearch

  attr_reader :search_criteria, :response 

  protected

  def create_list_response(response)
    Agoda::HotelListResponse.new(response) if response
  end

  def create_hotel_response(response)
    Agoda::HotelResponse.from_response(response) if response
  end

  def create_hotels_list(response_body)
    create_list_response Nokogiri.XML(response_body)
  end

  def search_params
    common_params
  end

  def common_params
    @params = {}
    add_location
    add_dates    
    add_persons_and_rooms
    add_rate_plan      
    add_language
    add_currency_code    
  end

  def add_location
    @params.merge!(:Radius=>0, :Latitude=>0, :Longitude=>0)
  end

  def add_persons_and_rooms
    @params.merge!(:Rooms => search_criteria.no_of_rooms, :Adults => search_criteria.no_of_adults.to_s, :Children=>0)
  end

  def add_rate_plan
    @params.merge!(:Rateplan => "Retail")
  end  

  def add_currency_code
    @params.merge!(:Currency => search_criteria.currency_code)
  end

  def add_language
    @params.merge!(:Language => 'en-us')
  end



  def add_dates
    @params.merge!({ 
      :CheckIn  => search_criteria.start_date.to_date.strftime('%Y-%m-%d'),
      :CheckOut => search_criteria.end_date.to_date.strftime('%Y-%m-%d')
    })      
  end

end
