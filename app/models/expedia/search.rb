class Expedia::Search

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {
    options: 'HOTEL_SUMMARY',
    numberOfResults: 100,
    # maxRatePlanCount: 30,
    supplierType: 'E'
  }

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end

  def self.by_destination(destination,search_criteria,params={})
    new(search_criteria).by_destination(destination, params)
  end

  def self.check_room_availability(hotel_id, search_criteria, params={})
    new(search_criteria).check_availability(hotel_id, params)
  end

  def by_destination(destination, options={})        
    params = search_params.merge(options).merge({destinationString: destination})   
    Expedia::Client.get_list(params) { |response| Expedia::HotelListResponse.new(response) if response}
  end

  def check_availability(hotel_id, options={})        
    params = search_params.merge(options).merge({hotelId: hotel_id, supplierType: ''})   
    Expedia::Client.get_availability(params) { |response| Expedia::HotelRoomAvailabilityResponse.new(response) if response}
  end

  protected
  def search_params
    @params = DEFAULT_PARAMS

    room_group = search_criteria.no_of_adults.to_s
    room_group += "#{search_criteria.children.join(',')}" if search_criteria.children?

    add_currency_code
    add_stars
    add_dates

    @params.merge!({ "room#{search_criteria.no_of_rooms}" => room_group})
  end

  def add_currency_code
    @params.merge!(currency_code: search_criteria.currency_code)
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
