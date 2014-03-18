class AppController < ApplicationController

  def index
    
  end

  def not_found
    render layout: 'error'
  end
end
