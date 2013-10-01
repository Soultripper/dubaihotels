class HotelAttributeLink < ActiveRecord::Base
  attr_accessible :append_text, :attribute_id, :ean_hotel_id, :language_code

  def self.cols
    "ean_hotel_id, attribute_id, language_code, append_text"   
  end  

  def self.amenities
    joins("inner join hotel_attributes on hotel_attributes.attribute_id = hotel_attribute_links.attribute_id and hotel_attributes.attribute_type = 'PropertyAmenity'")
  end

  def ean_hotel
    @ean_hotel ||= Hotel.find_by_ean_hotel_id self.ean_hotel_id
  end

  def hotel_attribute
    @hotel_attribute ||= HotelAttribute.find_by_attribute_id self.attribute_id
  end


end
