class HotelsHash

  attr_reader :hotels, :providers

  def initialize(hotels_list, provider_hotels_list)
    hash_hotels hotels_list
    hash_provider_hotels provider_hotels_list
  end


  def self.select_cols
    'id, star_rating, amenities, longitude, latitude, user_rating, provider_hotel_ranking, slug'
  end


  def self.by_location_slug(slug)
    hotels = Hotel.by_location_slug(slug).select(select_cols)
    provider_hotels_list = ProviderHotel.for_comparison(hotels.map(&:id))
    new hotels, provider_hotels_list
  end

  def self.by_location(location)
    Log.debug "HotelsHash::by_location - BEGIN"
    hotels = Hotel.by_location(location).select(select_cols)
    provider_hotels_list = ProviderHotel.for_comparison(hotels.map(&:id))
    Log.debug "HotelsHash::by_location - END"

    new hotels, provider_hotels_list
  end

  def self.by_hotel_ids(ids)
    hotels = Hotel.where(id: ids).select(select_cols)
    provider_hotels_list = ProviderHotel.for_comparison(ids)
    new hotels, provider_hotels_list
  end


  def [](name)
    providers[name]
  end

  def hotels_with_deals(inc_this_slug)
    hotel_comparisons.select {|h| h.has_a_deal? or h.slug == inc_this_slug}
  end

  def hotel_comparisons
    hotels.values
  end

  def provider_ids_for(provider)
    results = providers[provider.to_sym]
    results ? results.keys : []
  end

  def hotels_ids_for(provider)
    providers[provider.to_sym].value
  end

  def find_hotel_for(provider, id)
    hotels[providers[provider][id]]
  end

  protected

  def hash_hotels(hotels_list)
    Log.debug "HotelsHash::hash_hotels - BEGIN"
    @hotels = {}
    hotels_list.each {|hotel| hotels[hotel.id] = HotelComparisons.new(hotel)} 
    hotels_list = nil
    Log.debug "HotelsHash::hash_hotels - END"

    hotels
  end

  def hash_provider_hotels(provider_hotels_list)
    Log.debug "HotelsHash::hash_provider_hotels - BEGIN"

    @providers = {}

    provider_hotels_list.each do |provider_hotel|
      provider = provider_hotel.provider.to_sym
      hotel_id = provider_hotel.hotel_id
      providers[provider] ||= {}      
      providers[provider][provider_hotel.provider_id] = hotel_id
      hotels[hotel_id].provider_init(provider_hotel)
    end
    Log.debug "HotelsHash::hash_provider_hotels - END"

    provider_hotels_list = nil
  end

  def map_hotel(hotel_result)
    Hotel.new(hotel_result)
  end

end