class ReportsController < ApplicationController


  respond_to :csv
  layout nil

  http_basic_authenticate_with :name => "hot5reports", :password => "2 never back down"
 
  def index
    respond_with 
  end

  def by_location

    if location
      respond_to do |format|
        format.csv { render text: Reporter.hotels_by_location(location, order_clause) }
      end

      # respond_with 
    else
      head 501
    end
  end


  protected

  def location
    location ||= Location.find_by_slug params[:location]
  end

  def order_clause
    params[:order] || :star_rating
  end


end
