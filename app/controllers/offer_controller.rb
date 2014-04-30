class OfferController < ApplicationController

  layout 'tracking'

  def index    
    offer = params.except :action, :controller, :start_date, :end_date
    data = {
      provider: provider,
      search: search_criteria.as_json,
      offer: offer.merge(provider_id: provider_id),
      hotel: {
        id: hotel.id,
        name: hotel.name,
        address: hotel.address,
        city: hotel.city, 
        country_code: hotel.country_code,
        star_rating: hotel.star_rating,
        slug: hotel.slug
        }
      }.merge request: request_params
    Analytics.publish "clickthrough", data
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

  def provider_id
    hotel.send HotelsConfig::PROVIDER_IDS[provider.to_sym]
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
