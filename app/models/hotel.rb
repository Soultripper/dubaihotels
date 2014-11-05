class Hotel < ActiveRecord::Base
  include HotelScopes
  # self.table_name = "hotels_v2"

  # after_create :add_to_soulmate
  # before_destroy :remove_from_soulmate

  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  attr_accessible :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :description, 
                  :star_rating, :amenities,  :image_url, :thumbnail_url, :user_rating, :score, 
                  :provider_hotel_id, :provider_hotel_ranking, :provder_hotel_count, :slug

  attr_accessor :distance_from_location

  # has_many :images,    :class_name => "HotelImage", :order => 'default_image DESC, id ASC'
  has_many :provider_hotels
  has_many :provider_hotel_images

  scope :with_providers, includes(:provider_hotels)


  def images
    provider_hotel_images.by_ranked_order
  end

  def descriptions
    provider_hotels.map &:description
  end


  def find_provider(provider)
    provider_hotels.find {|f| f.provider == provider.to_s}
  end

  def has_provider(provider)
    provider_hotels.exists? provider: provider
  end

  def provider_ids
    ids = {}
    provider_hotels.each{|provider| ids[provider.provider.to_sym] = provider.provider_id}
    ids
  end



  def self.booking_only
    where('
      hotels.booking_hotel_id IS NOT NULL
      AND splendia_hotel_id IS NULL
      AND laterooms_hotel_id IS NULL
      AND ean_hotel_id IS NULL
      AND agoda_hotel_id IS NULL
      AND etb_hotel_id IS NULL
      AND venere_hotel_id IS NULL')
  end

  def self.without_main_image
    where('image_url IS NULL')
  end

  def self.without_images
    joins('LEFT JOIN hotel_images on hotel_images.hotel_id = hotels.id').
    where('hotel_images.id IS NULL')  
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

  
  def to_json
    Jbuilder.encode do |json|
      json.(self, :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, :user_rating,
                  :description, :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id, :venere_hotel_id, :slug)
    end
  end

  def soulmate_score
    total = 1
    [provider_hotel_count, user_rating, star_rating].each do |item|
      total = total * (item.to_i + 1)
    end

    total
  end


  def full_address
    country =  Providers::Booking::Country.lookup(country_code)
    desc = name
    if city.blank?
      desc = "#{desc}, #{state_province}"
    else
      desc = "#{desc}, #{city.capitalize}"
    end

    country.trim.blank? ? desc : "#{desc}, #{country}"

  end

  def name_with_city
    return name if city.blank?      
    "#{name}, #{city.capitalize}" 
  end

  def providers_to_json
    provider_hotels.map { |provider_hotel| provider_hotel.to_json }
  end


  def ratings

    rating = {overall:  user_rating.to_i}
    provider_hotels.each do |provider_hotel|
      rating[provider_hotel.provider.to_sym] = provider_hotel.user_rating.to_f
    end

    rating
  end

  def description_clean
    CGI::unescapeHTML(description.gsub(/<\/?[^>]*>/,""))
  end

  def to_soulmate
    {
      id: id,
      term: name,
      score: soulmate_score,
      data:{
        slug: slug,
        title: full_address
      }
    }.as_json
  end

  def to_analytics
    {
      id: id,
      name: name,
      address: address,
      city: city, 
      country_code: country_code,
      star_rating: star_rating,
      slug: slug,
      score: score
    }
  end


end
