class EWS::Search

  attr_reader :search_criteria, :response 

  DEFAULT_PARAMS =  {
    deeplinks: 'hoteldetails,ratedetails',
    hcom: true, 
    sort: :price,
    order: :asc,
    format: :json,
    allroomtypes: true,
    availonly: true
  }

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end

  protected

  def create_response(http_response, page_no=0)
    EWS::HotelListResponse.new(http_response, page_no)
  end

  def concat_responses(responses, page_start = 0)
    responses.map.with_index {|r,idx| EWS::HotelListResponse.new(JSON.parse(r.body), idx)}
  end

  def collect_hotels(list_responses)
    list_responses.flat_map {|list_response|  list_response.hotels}
  end

  def search_params
    @params = DEFAULT_PARAMS
    @params.merge!({
      adults: search_criteria.no_of_adults,
      currency: search_criteria.currency_code
      })
    add_children
    add_dates
  end


  def add_children
    return unless search_criteria.children?
    @params.merge!({childages: search_criteria.children.join(',')}) 
  end

  def add_dates
    dates = [search_criteria.start_date.to_date.strftime('%Y-%m-%d'), search_criteria.end_date.to_date.strftime('%Y-%m-%d')]
    @params.merge!({ 
      dates:   dates.join(',')
    })      
  end

end
