class AppController < ApplicationController

  respond_to :json
  def index
  end

  def currencies
    respond_with Currency.to_json
  end

  def user_info
    info =  {
      location:geo_location,
      currency: currency
    }
    respond_with   info
  end


  def privacy_policy
  end

  def not_found
    render layout: 'error'
  end
end
