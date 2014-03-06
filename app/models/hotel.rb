class Hotel < ActiveRecord::Base
  include HotelScopes
  after_save :add_to_soulmate
  before_destroy :remove_from_soulmate

  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  attr_accessible :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, :amenities,
                  :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id, :etb_hotel_id, :agoda_hotel_id, :description, :user_rating, :laterooms_hotel_id

  attr_accessor :distance_from_location

  has_many :images,    :class_name => "HotelImage", :order => 'default_image DESC'
  has_many :hotel_amenities, :class_name => "HotelsHotelAmenity"

  has_one :booking_hotel, :foreign_key => 'id', :primary_key => 'booking_hotel_id'
  has_one :ean_hotel, :foreign_key => 'id', :primary_key => 'ean_hotel_id'
  has_one :etb_hotel, :foreign_key => 'id', :primary_key => 'etb_hotel_id'

  has_many :booking_hotel_images, :foreign_key => 'booking_hotel_id', :primary_key => 'booking_hotel_id'
  has_many :hotel_images

  def self.cols
    "ean_hotel_id, sequence_number,name, address1,address2,city,state_province,postal_code ,country,latitude,longitude,airport_code,property_category,property_currency,star_rating,confidence, supplier_type,location,chain_code_id,region_id,high_rate,low_rate,check_in_time,check_out_time"
  end

  def self.booking_only
    where('
      hotels.booking_hotel_id IS NOT NULL
      AND splendia_hotel_id IS NULL
      AND laterooms_hotel_id IS NULL
      AND ean_hotel_id IS NULL
      AND agoda_hotel_id IS NULL
      AND etb_hotel_id IS NULL')
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
                  :description, :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id)
    end
  end

  def score
    total = 1
    [matches, user_rating, star_rating].each do |item|
      total = total * (item.to_i + 1)
    end

    total
  end


  def soulmate_desc
    country =  BookingCountry.lookup(country_code)
    desc = name
    if city.blank?
      desc = "#{desc}, #{state_province}"
    else
      desc = "#{desc}, #{city.capitalize}"
    end

    country.trim.blank? ? desc : "#{desc}, #{country}"

  end


  def ratings
    {
      overall:      user_rating,
      agoda:        agoda_user_rating.to_f * 10,
      booking:      booking_user_rating.to_f * 10,
      splendia:     splendia_user_rating.to_f,
      laterooms:    laterooms_user_rating.to_f * 16.6,
      easy_to_book: etb_user_rating.to_f * 20
    }
  end

  def to_soulmate
    {
      id: id,
      term: name,
      score: score,
      data:{
        slug: slug,
        title: soulmate_desc
      }
    }.as_json
  end


end
