class SearchController < ApplicationController

  # before_filter :publish_search, only: :index
  respond_to :html

  layout 'search'

  def index        
    @results = hotel_search.results.sort(sort)
    @user_channel = hotel_search.channel

    if(hotel_search.state != :new_search and hotel_search.state != :invalid)
      @results = search_results
    end

    @results = @results.select
   
  end

  def locations
    respond_with Location.autocomplete(query).sort_by {|l| l[:s].length}.take(10)
  end

  protected

  def cached_search
    @cached_search ||= HotelSearch.find params[:key]
  end

  def search_results
    hotel_search.results.sort(sort).filter(filters) 
  end

  def hotel_search
    @hotel_search ||= HotelSearch.find_or_create(location, search_criteria).start
  end

  def sort
    if location and location.distance_based? and params["sort"].blank?
      :distance
    else
      params["sort"] || :recommended
    end
  end

  def valid_search?
    search_criteria.valid? and location
  end

  def load_more?
    params[:load_more]
  end

  def location
    if coordinates
      @location ||= Location.my_location *coordinates
    else
      @location ||= Location.find_by_slug slug
    end
  end

  def slug
    @slug ||= (params[:id] || params[:hotel])
  end

  def coordinates
    @coordinates ||= params[:coordinates].split(',') if params[:coordinates]
  end

  def query
    @query ||= params[:query]
  end

  def publish_search
    Analytics.search publish_options
  end

  def publish_more_hotels
    Analytics.more_hotels(publish_options.merge(count: count)) if load_more?
  end

  def publish_options
    {
      search_criteria: search_criteria.as_json.merge(sort: sort),
      location: location.as_json,
      request_params: request_params
    }
  end


  helper_method :location, :search_criteria
end
