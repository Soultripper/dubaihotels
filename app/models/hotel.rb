class Hotel < ActiveRecord::Base
  include HotelScopes
  after_save :add_to_soulmate
  before_destroy :remove_from_soulmate

  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  attr_accessible :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, 
                  :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id, :etb_hotel_id, :agoda_hotel_id, :description, :user_rating, :laterooms_hotel_id

  attr_accessor :distance_from_location

  has_many :images,    :class_name => "HotelImage", :order => 'default_image DESC'
  has_many :hotel_amenities, :class_name => "HotelsHotelAmenity"

  has_one :booking_hotel, :foreign_key => 'id', :primary_key => 'booking_hotel_id'
  has_one :ean_hotel, :foreign_key => 'id', :primary_key => 'ean_hotel_id'
  has_one :etb_hotel, :foreign_key => 'id', :primary_key => 'etb_hotel_id'

  def self.cols
    "ean_hotel_id, sequence_number,name, address1,address2,city,state_province,postal_code ,country,latitude,longitude,airport_code,property_category,property_currency,star_rating,confidence, supplier_type,location,chain_code_id,region_id,high_rate,low_rate,check_in_time,check_out_time"
  end

  def self.soulmate_loader
    @soulmate_loader ||= Soulmate::Loader.new("hotel")
  end

  def self.load_into_soulmate
    items = all.map &:to_soulmate   
    soulmate_loader.load(items)
  end

  def add_to_soulmate
    Hotel.soulmate_loader.add(to_soulmate)
  end

  def remove_from_soulmate
    Hotel.soulmate_loader.remove("id" => self.id)
  end  

  def provider_deals
    @provider_deals ||= providers_init
  end

  def sorted_deals
    # @sorted_deals ||= provider_deals.sort_by! do |p| 
    #   p[:min_price] ? p[:min_price].to_f : 9999999.9
    # end

    best_offers     = provider_deals.select {|d| d[:min_price].to_f == offer[:min_price].to_f}
    non_best_offers = provider_deals.select {|d| d[:min_price].to_f != offer[:min_price].to_f}.sort_by! do |p| 
      p[:min_price] ? p[:min_price].to_f : 9999999.9
    end
    @sorted_deals ||= best_offers.shuffle.concat non_best_offers
  end

  # def random_best_offer
  #   min_price = sorted_deals.first[:min_price]
  #   best_offers = sorted_deals.select {|d| d[:min_price].to_f == min_price.to_f}
        
  #   sorted_deals.slice! 0,best_offers.length      
  #   best_offers.shuffle!
  #   sorted_deals << best_offers

  #   best_offers.sample
  # end

  def find_provider_deal(name)
    provider_deals.find {|deal| deal[:provider] == name}
  end


  def providers_init
    providers = []
    providers << provider_init(:hotels)       if ean_hotel_id
    providers << provider_init(:booking)      if booking_hotel_id
    providers << provider_init(:easy_to_book) if etb_hotel_id
    providers << provider_init(:agoda)        if agoda_hotel_id
    providers << provider_init(:splendia)     if splendia_hotel_id
    providers << provider_init(:laterooms)    if laterooms_hotel_id
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

  def ranking
    return find_provider_deal(:booking)[:ranking]*-1 if booking?
    return find_provider_deal(:hotels)[:ranking] if hotels_dot_com?
    999
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
    # provider_deals[data[:provider]] = data
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

  def to_json
    Jbuilder.encode do |json|
      json.(self, :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, :user_rating,
                  :description, :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id)
    end
  end

  def to_soulmate
    {
      id: id,
      term: name,
      score: star_rating,
      data:{
        url: "hotels/#{id}",
        title: "#{name}, #{city}, #{Country.lookup(country_code)}"
      }
    }.as_json
  end


end
