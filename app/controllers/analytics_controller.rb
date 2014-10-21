class AnalyticsController < ApplicationController

  # skip_before_filter :verify_authenticity_token

  after_filter :cors_set_access_control_headers


  layout :none

  def geolocate_error    
    #Analytics.publish "geolocate_error", request: request_params
    head 200
  end

  protected

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end


end
