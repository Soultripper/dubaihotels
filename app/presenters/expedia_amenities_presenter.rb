class ExpediaAmenitiesPresenter < BasePresenter
  extend Forwardable

  presents :hotel_attribute

  def model
    @model ||= Hotel.find_by_ean_hotel_id hotel.hotelId
  end

  def wifi?
    match? 2390, 2403
  end

  def parking?
    match? 323, 2011, 2013, 2133, 2132
  end

  def restaurant?
    
  end

  def match?(*ids)
    ids.include? hotel_attribute.attributeId
  end


end