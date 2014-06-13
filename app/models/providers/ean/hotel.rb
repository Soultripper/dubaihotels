class Providers::Ean::Hotel < Providers::Base

  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  attr_accessible :address1, :address2, :airport_code, :chain_code_id, :check_in_time, :check_out_time, 
        :city, :confidence, :country, :ean_hotel_id, :high_rate, :latitude, :location, :longitude, :low_rate, 
        :name, :postal_code, :property_category, :property_currency, :region_id, :sequence_number, :star_rating, 
        :state_province, :supplier_type

  has_many :images,     :class_name => "EanHotelImage"
  has_many :properties, :class_name => "EanHotelAttributeLink"

  def ean_hotel_id
    self.id
  end

  def self.cols
    "id, sequence_number,name, address1,address2,city,state_province,postal_code ,country,latitude,longitude,airport_code,property_category,property_currency,star_rating,confidence, supplier_type,location,chain_code_id,region_id,high_rate,low_rate,check_in_time,check_out_time"
  end

  def amenities
    @amenities ||= properties.amenities
  end

  def fetch_hotel
    @hotel||=Hotel.find_by_ean_hotel_id id
  end

end
