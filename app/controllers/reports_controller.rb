class ReportsController < ApplicationController


  respond_to :csv,  :text, :html
  layout nil

  http_basic_authenticate_with :name => "hot5reports", :password => "2 never back down"
 
  def index
    respond_with 
  end

  def by_location

    if location
      @report = Reporter.hotels_by_location(location, order_clause)
      respond_to do |format|
        format.csv  { render text:  @report}
        format.text { render text:  @report}
        format.html
      end

      # respond_with 
    else
      head 501
    end
  end



  protected

  def report
    @report
  end

  def location
    location ||= Location.find_by_slug params[:location]
  end

  def order_clause
    params[:order] || :star_rating
  end

  helper_method :report


end
