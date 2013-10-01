class Hotel < ActiveRecord::Base

  attr_accessible :address1, :address2, :airport_code, :chain_code_id, :check_in_time, :check_out_time, 
        :city, :confidence, :country, :ean_hotel_id, :high_rate, :latitude, :location, :longitude, :low_rate, 
        :name, :postal_code, :property_category, :property_currency, :region_id, :sequence_number, :star_rating, 
        :state_province, :supplier_type

  # has_many :hotel_images, :foreign_key => 'ean_hotel_id'

  def self.cols
    "ean_hotel_id, sequence_number,name, address1,address2,city,state_province,postal_code ,country,latitude,longitude,airport_code,property_category,property_currency,star_rating,confidence, supplier_type,location,chain_code_id,region_id,high_rate,low_rate,check_in_time,check_out_time"
  end

  def ean_hotel_images
    @ean_hotel_images ||= HotelImage.where(ean_hotel_id: self.ean_hotel_id).to_a
  end

  def ean_attributes
    @ean_attributes ||= HotelAttributeLink.where(ean_hotel_id: self.ean_hotel_id).to_a
  end

  def ean_amenities
    @ean_amenities ||= HotelAttributeLink.where(ean_hotel_id: self.ean_hotel_id).amenities
  end
end
