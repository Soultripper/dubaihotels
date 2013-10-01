class ExpediaHotelPresenter < BasePresenter
  extend Forwardable

  presents :hotel
  def_delegators :model, :id, :name, :deepLink, :star_rating, :confidence, :to_gmaps4rails, :latitude, :longitude, :address1, :city

  def model
    @model ||= Hotel.find_by_ean_hotel_id hotel.hotelId
  end

  def hotelId
    id || hotel.hotelId
  end

  def thumbnail
    default_image.thumbnail_url if default_image
  end

  def image
    default_image.url if default_image
  end

  def thumbnail_link
    link_content {  image_tag thumbnail, size: "30x30" }
  end

  def image_link
    link_content {  image_tag image, size: "126x182" }
  end

  def link_content
    content_tag :a,  href: '',  alt:"Book now at #{name}", target: '_blank' do 
      yield if block_given?
    end
  end

  def rating
    "#{confidence}/100"
  end

  def total(total_nights)
    unit = Currency.codes[Expedia.currency_code.upcase.to_sym]
    Utilities.to_currency hotel.total.to_f / total_nights, {precision:0, unit: unit}
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