require 'location'
class HotelComparisons
  extend Forwardable

  attr_reader :hotel_id, :stars, :longitude, :latitude, :user_rating, :ranking, :provider_deals
  attr_accessor :distance_from_location, :hotel

  def_delegators  :@hotel, :id, :star_rating, :longitude, :amenities, :latitude, 
                  :user_rating, :provider_hotel_count, :provider_hotel_ranking, :slug, :find_provider

  def self.select_cols
    'id, star_rating, amenities, longitude, latitude, user_rating, provider_hotel_count, provider_hotel_ranking, slug'
  end

  def initialize(hotel_details)
    @hotel            = hotel_details
    @provider_deals   = []
  end

  def self.by_location(location, proximity_in_metres = 20000)
    Hotel.by_location(location).select(select_cols).map {|hotel| new hotel}
  end

  def self.by_provider_ids(key, ids)
    Hotel.where(key => ids.to_a).select(select_cols).map {|hotel| new hotel}  
  end

  def self.by_ids(ids)
    Hotel.where(id: ids.to_a).select(select_cols).map {|hotel| new hotel}  
  end

  def hotel=(hotel)
    @hotel = hotel
  end

  def has_a_deal?
    @has_a_deal
  end

  def recommended_score
    (hotel.ranking || 0)
  end
  
  def [](key)
    hotel[key]
  end

  def fetch_hotel
    @hotel ||= Hotel.find hotel_id
  end

  def find_provider_deal(name)
    provider_deals.find {|deal| deal[:provider] == name} || {}
  end

  def has_rooms_for_provider?(name)
    deal = find_provider_deal name
    deal[:rooms]
  end


  # def providers_init
  #   providers = []
  #   HotelsConfig::PROVIDER_IDS.each do |provider_key, provider_id|
  #     if hotel[provider_id]  
  #       providers << provider_init(provider_key) 
  #     end
  #   end
  #   providers
  # end

  def provider_init(provider_hotel)
    provider_deals <<
    {
      provider: provider_hotel.provider.to_sym,
      #link: provider_hotel.hotel_link,
      provider_id: provider_hotel.provider_id,
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

  def rooms_merged(other_hotel)
    return rooms unless other_hotel
    other_providers = other_hotel.loaded_providers
    other_providers.each do |other_provider|
      add_provider_deal(other_provider)
    end 
    rooms
  end

  def loaded_providers
    provider_deals.select {|provider| provider[:loaded]===true }
  end

  def distance_from(location)
    return unless location and location.longitude and location.latitude
    GeoDistance::Haversine.geo_distance( location.latitude, location.longitude, latitude, longitude).to_meters
  end

  def central?
    return false unless distance_from_location
    distance_from_location < 3000 and distance_from_location > 0  
  end

  def provider_description
  end


  def compare_and_add(provider_hotel)
    return unless provider_hotel
    add_provider_deal provider_hotel
    sort_by_price
    randomize_best_offer   
  end

  def add_provider_deal(new_provider)
    @has_a_deal = true
    new_provider[:loaded] = true
    idx = provider_deals.index {|deal| deal[:provider] == new_provider[:provider]}

    # if(provider_deals[idx][:link].empty?)
    # end

    add_rooms new_provider, provider_deals[idx]
    # if idx 
      # debug_deal(provider_deals[idx], data)
    # data[:rooms] = provider_deals[idx][:rooms] if data[:rooms].empty?

    # if data[:rooms]
    #   data[:rooms].each {|room| room[:link] = provider_deals[idx][:link] if room[:link].blank?}
    # end
    provider_deals[idx] = new_provider 
    # else
    #   Log.debug "--------------------NO HOTEL FOUND ---------------------"
    #   provider_deals << data
    # end
  end  

  def add_rooms(new_provider, current_provider)

    new_provider[:rooms] = current_provider[:rooms] if new_provider[:rooms].blank?
    if new_provider[:rooms]
      new_provider[:rooms].each {|room| room[:link] = current_provider[:link] if room[:link].blank?}
    end
  end

  def debug_deal(loaded, new_deal)
    return unless loaded[:provider] == :booking
    Log.info loaded
    Log.info new_deal
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
    offer[:provider_id]  = provider[:provider_id]
    #offer[:link]      = provider[:link]
    offer[:min_price] = provider[:min_price]
    offer[:max_price] = provider_deals.select {|d|  Utilities.nil_round(d[:min_price]) != 0}.last[:min_price]
    offer[:saving]    = ((1 - offer[:min_price].to_f / offer[:max_price].to_f) * 100) if offer[:max_price].to_f > 0
    offer
  end

end