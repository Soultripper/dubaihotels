class HotelV2 < ActiveRecord::Base
  include HotelScopes

  self.table_name = "hotels_v2"

  after_save :add_to_soulmate
  before_destroy :remove_from_soulmate

  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  attr_accessible :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, :amenities,
                  :description, :user_rating, :provider_hotel_ranking, :score, :image_url, :thumbnail_url, :slug

  attr_accessor :distance_from_location

  has_many :images,    :class_name => "HotelImage", :order => 'default_image DESC, id ASC'
  has_many :provider_hotels



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
    [matches, user_rating, star_rating].each do |item|
      total = total * (item.to_i + 1)
    end

    total
  end


  def full_address
    country =  BookingCountry.lookup(country_code)
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


  def ratings
    {
      overall:      user_rating.to_i,
      agoda:        (agoda_user_rating.to_f * 10).to_i,
      booking:      (booking_user_rating.to_f * 10).to_i,
      splendia:     splendia_user_rating.to_i,
      laterooms:    (laterooms_user_rating.to_f * 16.6).to_i,
      easy_to_book: (etb_user_rating.to_f * 20).to_i
    }
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
