class EasyToBook::Search < ProviderHotelSearch

  attr_reader :search_criteria, :response 

  def self.by_city(city_id, search_criteria, params={})
    new(search_criteria).by_city(city_id, params)
  end

  def self.check_availability(hotel_id, search_criteria, params={})
    new(search_criteria).check_availability(hotel_id, params)
  end

  def by_city(city_id, options={})        
    params = search_params.merge(options).merge({:Cityid => city_id})     
    create_list_response EasyToBook::Client.search_availability(params)
  end

  def check_availability(hotel_id, options={})   
    params = common_params.merge(options).merge({:Hotelid => hotel_id})   
    EasyToBook::Client.get_availability(params)
  end


  def create_list_response(xml)
    EasyToBook::HotelListResponse.new(xml) if xml
  end
  
  def create_hotels_list(response_body)
    xml = Nokogiri.XML(response_body)
    hotels_list  = create_list_response xml
    xml = nil
    hotels_list
  end

  protected


  def create_hotel_response(response)
    EasyToBook::HotelResponse.from_response(response) if response
  end

  def search_params
    common_params.merge :SlimResponse=>1, :CommissionEnabled=>0, :MetaPrice=>1
  end

  def common_params
    @params = {}
    add_dates    
    add_language
    add_persons_and_rooms
    add_currency_code
  end

  def add_persons_and_rooms
    @params.merge!(:Noofpersons => search_criteria.no_of_adults.to_s, :Nofrooms => search_criteria.no_of_rooms)
  end

  def add_currency_code
    @params.merge!(:Currency => search_criteria.currency_code)
  end

  def add_language
    @params.merge!(:Language => 'en')
  end

  # def add_stars
  #   return if search_criteria.all_stars? 
  #   @params.merge!({           
  #     minStarRating:  search_criteria.min_stars,
  #     maxStarRating:  search_criteria.max_stars
  #   })
  # end

  def add_dates
    @params.merge!({ 
      :Startdate  => search_criteria.start_date.to_date.strftime('%Y-%m-%d'),
      :Enddate    => search_criteria.end_date.to_date.strftime('%Y-%m-%d')
    })      
  end

end
