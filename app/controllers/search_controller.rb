class SearchController < ApplicationController

  before_filter :validate_search

  respond_to :json

  layout 'search'

  def index        

    # respond_with @hotel_search

    respond_to do |format|
      format.json do 

        if !search_criteria.valid? or !location
          head 400
          return
        end

        publish_more_hotels

        # @results = hotel_search.results.sort(sort).filter(filters).paginate(page_no, page_size)        
        @results = hotel_search.results.sort(sort).filter(filters).select(count)        
        render json: @results

      end
      format.html do

        unless search_criteria.valid? and location
          return
        end

        publish_search

        @results = hotel_search.results.sort(sort)

        if(hotel_search.state!=:new_search)
          @results = @results.filter(filters)  
        end

        @results = @results.select

        @user_channel = hotel_search.channel
      end
    end

  end

  def hotel_search
    @hotel_search ||= HotelSearch.find_or_create(location, search_criteria).start
  end

  def locations
    respond_with Location.autocomplete(query).sort_by {|l| l[:s].length}.take(10)
  end

  protected

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

  def sort
    if location and location.distance_based? and params["sort"].blank?
      :distance
    else
      params["sort"] || :recommended
    end
  end

  def validate_search
    search_criteria.valid?
  end

  def load_more?
    params[:load_more]
  end

  def location
    if coordinates
      @location = Location.my_location *coordinates
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

  helper_method :location, :search_criteria
end
