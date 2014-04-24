class OfferController < ApplicationController

  layout 'tracking'

  def index        

  end


  protected


  def hotel
    @hotel ||= Hotel.find hotel_id
  end

  def hotel_image
    @hotel_image ||= hotel.images.first
  end

  def provider
    params[:provider]
  end

  def provider_name
    HotelsConfig::PROVIDER_IDS[provider]
  end


  def target_url
    @target_url ||= params[:target_url]
  end

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

  helper_method :meta_refresh, :hotel, :hotel_image, :provider, :saving, :max_price, :price, :search_criteria


end
