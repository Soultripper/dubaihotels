class AppController < ApplicationController

  respond_to :json
  def index
    
  end

  def currencies
    respond_with Currency.to_json
  end

  def privacy_policy
  end

  def not_found
    render layout: 'error'
  end
end
