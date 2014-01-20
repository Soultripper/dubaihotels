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

  def distance_from(location)
    return unless location.longitude and location.latitude
    GeoDistance::Haversine.geo_distance( location.latitude, location.longitude, latitude, longitude).to_meters
  end

  def compare_and_add(provider_hotel)
    return unless provider_hotel
    add_provider_deal provider_hotel
    sort_by_price
    randomize_best_offer   
  end

  def add_provider_deal(data)
    data[:loaded] = true
    idx = provider_deals.index {|deal| deal[:provider] == data[:provider]}
    idx ? provider_deals[idx] = data : provider_deals << data
  end  

  def sort_by_price
    provider_deals.sort_by! {|deal| deal[:min_price].to_i}
  end

  def randomize_best_offer
    min_price     = provider_deals.first[:min_price].to_i
    best_offers   = provider_deals.select {|d| d[:min_price].to_i == min_price}
    current_best  = provider_deals.first
    random_idx    = Random.new.rand(best_offers.count)
    random_best   = best_offers[random_idx]
    provider_deals[0] = random_best
    provider_deals[random_idx] = current_best

    set_best_offer random_best
  end

  def set_best_offer(provider)    
    offer[:provider]  = provider[:provider]
    offer[:link]      = provider[:link]
    offer[:min_price] = provider[:min_price]
    offer[:max_price] = provider_deals.last[:min_price]
    offer
  end

end