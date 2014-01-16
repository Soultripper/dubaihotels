require 'location'
class HotelComparisons
  extend Forwardable

  attr_reader :hotel_id, :stars, :longitude, :latitude, :user_rating, :ranking, :provider_deals
  attr_accessor :distance_from_location, :hotel

  def_delegators :@hotel, :id, :star_rating, :longitude, :latitude, :user_rating, :ranking, :booking_hotel_id, :ean_hotel_id, :splendia_hotel_id, :etb_hotel_id, :laterooms_hotel_id, :agoda_hotel_id, :laterooms_url, :booking_url

  def self.select_cols
    'id, star_rating, longitude, latitude, user_rating, ranking, laterooms_url, booking_url, ' + HotelsConfig::PROVIDER_IDS.map {|k,v| v}.join(', ')
  end

  def initialize(hotel_details)
    @hotel            = hotel_details
    # @hotel_id       = hotel_details[:id]
    # @stars          = hotel_details[:star_rating].to_f
    # @longitude      = hotel_details[:longitude]
    # @latitude       = hotel_details[:latitude]
    # @user_rating    = hotel_details[:user_rating].to_f
    # @ranking        = hotel_details[:ranking].to_f 
    @provider_deals = providers_init
  end

  def self.by_location(location, proximity_in_metres = 20000)
    Hotel.by_location(location).select(select_cols).map {|hotel| new hotel}
  end

  def self.by_provider_ids(key, ids)
    Hotel.where(key => ids.to_a).select(select_cols).map {|hotel| new hotel}  
  end

  def hotel=(hotel)
    @hotel = hotel
  end

  def [](key)
    hotel[key]
  end

  def fetch_hotel
    @hotel ||= Hotel.find hotel_id
  end

  def sorted_deals
    best_offers     = provider_deals.select {|d| d[:min_price].to_i == offer[:min_price].to_i}
    non_best_offers = provider_deals.select {|d| d[:min_price].to_i != offer[:min_price].to_i}.sort_by! do |p| 
      p[:min_price] ? p[:min_price].to_f : 9999999.9
    end
    @sorted_deals ||= best_offers.shuffle.concat non_best_offers
  end

  def find_provider_deal(name)
    provider_deals.find {|deal| deal[:provider] == name}
  end

  def providers_init
    providers = []
    HotelsConfig::PROVIDER_IDS.each do |provider_key, provider_id|
      if hotel[provider_id]  
        providers << provider_init(provider_key) 
      end
    end
    providers
  end

  def provider_init(name)
    {
      provider: name,
      loaded: false
    }
  end

  def offer
    @offer ||= {}
  end

  def booking?
    deal = find_provider_deal(:booking) 
    deal and deal[:loaded]
  end

  def hotels_dot_com?
    deal = find_provider_deal(:hotels)
    deal and deal[:loaded]
  end

  def compare_and_add(provider_hotel)
    compare provider_hotel 
    update_provider_deal provider_hotel
  end

  def distance_from(location)
    GeoDistance::Haversine.geo_distance( location.latitude, location.longitude, latitude, longitude).to_meters
  end

  def compare(provider_hotel)
    return unless provider_hotel
    if (provider_hotel[:min_price].to_f < offer[:min_price].to_f) || offer[:min_price].blank?
      set_best_offer provider_hotel
    end
    offer[:max_price]  =  provider_hotel[:min_price].to_f if (provider_hotel[:min_price].to_f > offer[:min_price].to_f) || offer[:max_price].blank?
  end

  def best_offer
    random_best = sorted_deals.first
    if random_best
      offer[:provider]  = random_best[:provider]
      offer[:link]      = random_best[:link]
      offer[:min_price] = random_best[:min_price]
    end
    offer
  end

  def set_best_offer(provider_hotel)
    offer[:min_price] = provider_hotel[:min_price].to_f
    offer[:provider]  = provider_hotel[:provider]
    offer[:link]      = provider_hotel[:link]
  end

  def update_provider_deal(data)
    data[:loaded] = true
    idx = provider_deals.index {|deal| deal[:provider] == data[:provider]}
    idx ? provider_deals[idx] = data : provider_deals << data
  end  
end