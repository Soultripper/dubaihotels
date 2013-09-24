class ExpediaHotelPresenter < BasePresenter
  extend Forwardable

  presents :hotel
  def_delegators :hotel, :id, :name, :deepLink, :thumbNailUrl, :hotelRating, :confidenceRating

  def model
    @model ||= Expedia::Hotel.find(hotel.hotelId)
  end

  def hotelId
    id || hotel.hotelId
  end

  def root_image_url
    "http://images.travelnow.com/"
  end

  def thumbnail
    "#{root_image_url}#{thumbNailUrl}"
  end

  def image
    "#{root_image_url}#{thumbNailUrl.gsub('_t','_b')}"
  end

  def thumbnail_link
    link_content {  image_tag thumbnail, size: "30x30" }
  end

  def image_link
    link_content {  image_tag image, size: "126x182" }
  end

  def link_content
    content_tag :a,  href: deepLink,  alt:"Book now at #{name}", target: '_blank' do 
      yield if block_given?
    end
  end

  def rating
    "#{confidenceRating}/100"
  end

  def total
    unit = Currency.codes[Expedia.currency_code.upcase.to_sym]
    Utilities.to_currency hotel.total, {precision:0, unit: unit}
  end

  def images
    return [] unless model
    model.images.take(10)
  end

  def main_image
    return [] unless model
    images.first['url']
  end



end