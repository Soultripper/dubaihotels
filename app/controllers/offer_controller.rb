class OfferController < ApplicationController

  layout 'tracking'

  before_filter :index, :publish_clickthrough

  def index    

  end


  protected

  protected 
  def publish_clickthrough
    options = {
      offer: params.except(:action, :controller, :start_date, :end_date).merge(provider_id: provider_id),
      provider: provider,
      search_criteria: search_criteria.as_json,
      hotel: hotel.to_analytics,
      request_params: request_params
    }

    # HotelScorer.score(hotel, :clickthrough) if Analytics.clickthrough(options)
  end


  def hotel
    @hotel ||= Hotel.joins(:provider_hotels).find hotel_id
  end

  def hotel_image
    @hotel_image ||= hotel.image_url
  end

  def provider
    params[:provider]
  end

  def provider_id
    hotel.provider_hotels.find {|p| p.provider==provider}.provider_id
  end


  def target_url
    @target_url ||= params[:target_url]
  end

  # def unescaped_url
  #   url = target_url
  #   if url.index('url=')
  #     pos = url.index('url=') + 4
  #     qs = url[pos..-1]
  #     url[pos..-1] = CGI.escape(qs) 
  #     url
  #   else
  #     CGI.unescape target_url
  #   end
  # end


  def hotel_id
    @hotel_id ||= params[:hotel_id]
  end

  def price
    @price ||= params[:price]
  end

  def meta_refresh
    @meta_refresh = "5;URL=#{target_url}"
  end

  def saving
    @saving ||= params[:saving].to_i
  end

  def max_price
    @max_price ||= params[:max_price]
  end

  helper_method :meta_refresh, :hotel, :hotel_image, :provider, :saving, :max_price, :price, :search_criteria, :target_url


end
