class HotelPresenter < BasePresenter
  extend Forwardable

  presents :hotel
  def_delegators :hotel, :id, :name, :deepLink, :star_rating, :confidence, :latitude, :longitude, :address1, :city

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

  def total_rooms
    hotel.rooms_count
  end

  def images
    hotel.ean_hotel_images.take(10)
  end

  def default_image
    hotel.ean_hotel_images.find &:default_image    
  end

  def address
    "#{address1}, #{city}"
  end

end