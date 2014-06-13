require 'location'
class HotelComparisons
  extend Forwardable

  attr_reader :hotel_id, :stars, :longitude, :latitude, :user_rating, :ranking, :provider_deals
  attr_accessor :distance_from_location, :hotel

  def_delegators  :@hotel, :id, :star_rating, :longitude, :amenities, :latitude, 
                  :user_rating, :matches, :ranking, :booking_hotel_id, :ean_hotel_id, 
                  :splendia_hotel_id, :etb_hotel_id, :laterooms_hotel_id, :agoda_hotel_id, 
                  :agoda_user_rating, :laterooms_user_rating, :etb_user_rating, :splendia_user_rating, :booking_user_rating,
                  :laterooms_url, :booking_url, :slug, :venere_hotel_id

  def self.select_cols
    'id, star_rating, amenities, longitude, latitude, user_rating, matches, ranking, laterooms_url, booking_url, slug, ' + HotelsConfig::PROVIDER_IDS.map {|k,v| v}.join(', ')
  end

  def initialize(hotel_details)
    @hotel            = hotel_details
    @provider_deals   = providers_init
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

  def has_a_deal?
    provider_deals.find {|deal| deal[:loaded]==true}
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

  def main_image
    images.first || []
  end

  def images(count=11)
    hotel.images.limit(count) || []
  end

  def offer
    @offer ||= {}
  end


  def rooms
    @rooms = loaded_providers.map {|deal| deal[:rooms]}.flatten.compact
    @rooms.sort_by {|room| room[:price].to_f} if @rooms
  end

  def loaded_providers
    provider_deals.select {|provider| provider[:loaded]===true }
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
    @distance ||= GeoDistance::Haversine.geo_distance( location.latitude, location.longitude, latitude, longitude).to_meters
  end

  def central?(location)
    distance = distance_from(location) 
    return false unless distance
    distance < 3000 and distance > 0  
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
    provider_deals.sort_by! {|deal| Utilities.nil_round(deal[:min_price], 999999)}
  end

  def randomize_best_offer
    min_price     = Utilities.nil_round(provider_deals.first[:min_price])
    best_offers   = provider_deals.select {|d| Utilities.nil_round(d[:min_price]) == min_price}
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
    offer[:max_price] = provider_deals.select {|d|  Utilities.nil_round(d[:min_price]) != 0}.last[:min_price]
    offer[:saving]    = ((1 - offer[:min_price].to_f / offer[:max_price].to_f) * 100) if offer[:max_price].to_f > 0
    offer
  end

end