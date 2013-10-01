class ExpediaRoomPresenter < BasePresenter
  extend Forwardable

  presents :hotel_room


  def description
    hotel_room.roomTypeDescription
  end

  def total(total_nights)
    unit = Currency.codes[Expedia.currency_code.upcase.to_sym]
    Utilities.to_currency hotel_room.total.to_f / total_nights, {precision:0, unit: unit}
  end

  def images
    return [] unless model
    model.ean_hotel_images.take(10)
  end

  def default_image
    return [] unless model
    model.ean_hotel_images.find &:default_image    
  end

  def address
    "#{address1}, #{city}"
  end

end