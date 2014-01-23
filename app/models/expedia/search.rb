class Expedia::Search

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {
    # options: 'ROOM_RATE_DETAILS',
    numberOfResults: 200,
    maxRatePlanCount: 10,
    supplierType: 'E|V'
  }

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end

  def self.by_destination(location, search_criteria, params={})
    new(search_criteria).by_destination(location, params)
  end

  def self.by_location(location, search_criteria, params={})
    new(search_criteria).by_location(location, params)
  end

  def self.by_hotel_ids(hotel_ids, search_criteria,params={})
    new(search_criteria).by_hotel_ids(hotel_ids, params)
  end

  def self.check_room_availability(hotel_id, search_criteria, params={})
    new(search_criteria).check_availability(hotel_id, params)
  end

  def by_location(location, options={})        
    params = search_params.merge(options).merge({latitude: location.latitude, longitude: location.longitude, searchRadiusUnit: 'KM', searchRadius: 20})   
    create_list_response Expedia::Client.get_list(params)
  end

  def by_destination(location, options={})        
    params = search_params.merge(options).merge({ destinationString: "#{location.name}, #{location.country_code}"})   
    create_list_response Expedia::Client.get_list(params)
  end

  def by_hotel_ids(hotel_ids, options={})        
    params = search_params.merge(options).merge({hotelIdList: hotel_ids.join(',')})   
    create_list_response  Expedia::Client.get_list(params)
  end

  def check_availability(hotel_id, options={})        
    params = search_params.merge(options).merge({hotelId: hotel_id, supplierType: ''})   
    create_availability_response Expedia::Client.get_availability(params)
  end

  protected

  def concat(responses)
    Log.debug "Combining #{responses.count} expedia responses"
    responses.flat_map {|response| create_list_response(response)}
  end

  def create_list_response(response)
    Expedia::HotelListResponse.new(response) if response
  end

  def create_availability_response(response)
    Expedia::HotelRoomAvailabilityResponse.new(response) if response
  end

  def search_params
    @params = DEFAULT_PARAMS

    room_group = search_criteria.no_of_adults.to_s
    room_group += "#{search_criteria.children.join(',')}" if search_criteria.children?

    add_currency_code
    # add_stars
    add_dates

    @params.merge!({ "room#{search_criteria.no_of_rooms}" => room_group})
  end

  def add_currency_code
    @params.merge!(currencyCode: search_criteria.currency_code)
  end

  def add_stars
    return if search_criteria.all_stars? 
    @params.merge!({           
      minStarRating:  search_criteria.min_stars,
      maxStarRating:  search_criteria.max_stars
    })
  end

  def add_dates
    @params.merge!({ 
      arrivalDate:    search_criteria.start_date.to_date.strftime('%m/%d/%Y'),
      departureDate:  search_criteria.end_date.to_date.strftime('%m/%d/%Y')
    })      
  end

  def self.sort_options
    {
      'exact' => 'NO_SORT',
      'popularity' => 'CITY_VALUE',
      'value' => 'OVERALL_VALUE',
      'promo' => 'PROMO', 
      'price' => 'PRICE',
      'price_reverse' => 'PRICE_REVERSE',
      'prive_average' => 'PRIVE_AVERAGE',
      'rating' => 'QUALITY', 
      'rating_reverse' => 'QUALITY_REVERSE',
      'a_z' => 'ALPHA',
      'proximity' => 'PROXIMITY',
      'postal_code' => 'POSTAL_CODE'
    }
  end 

end
