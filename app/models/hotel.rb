class Hotel < ActiveRecord::Base
  include HotelScopes
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  attr_accessible :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, 
                  :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id, :description

  attr_accessor :distance_from_location

  has_many :images,    :class_name => "HotelImage", :order => 'default_image DESC'
  has_many :hotel_amenities, :class_name => "HotelsHotelAmenity"

  def self.cols
    "ean_hotel_id, sequence_number,name, address1,address2,city,state_province,postal_code ,country,latitude,longitude,airport_code,property_category,property_currency,star_rating,confidence, supplier_type,location,chain_code_id,region_id,high_rate,low_rate,check_in_time,check_out_time"
  end

  def provider_deals
    @provider_deals ||= {}
  end

  def offer
    @offer ||= {}
  end

  def ranking
    return provider_deals[:booking][:ranking]*-1 if booking?
    return provider_deals[:expedia][:ranking] if booking?
    999
  end

  def booking?
    booking
  end

  def booking
    provider_deals[:booking]
  end

  def expedia?
    expedia
  end

  def expedia
    provider_deals[:booking]
  end

  def compare_and_add(hotel_response, search_criteria, location)
    data = hotel_response.commonize(search_criteria, location)
    compare data 
    provider_deals[data[:provider]] = data
  end

  def compare(provider_hotel)
    return unless provider_hotel
    if (provider_hotel[:min_price].to_f < offer[:min_price].to_f) || offer[:min_price].blank?
      offer[:min_price] = provider_hotel[:min_price].to_f
      offer[:provider]  = provider_hotel[:provider]
    end
    offer[:max_price]  =  provider_hotel[:min_price].to_f if (provider_hotel[:min_price].to_f > offer[:min_price].to_f) || offer[:max_price].blank?
  end

  def to_json
    Jbuilder.encode do |json|
      json.(self, :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, 
                  :description, :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id)
      # json.images self.images.take(10), :url, :thumbnail_url, :caption, :width, :height
      # json.provider self.provider_deals
    end
  end

end
