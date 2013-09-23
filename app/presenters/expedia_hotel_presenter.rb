class ExpediaHotelPresenter < BasePresenter
  extend Forwardable

  presents :hotel
  def_delegators :hotel, :id, :name, :deepLink, :thumbNailUrl, :hotelRating, :confidenceRating

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
    content_tag :a,  href: deepLink,  alt:"Book now at #{name}", target: '_blank' do 
        image_tag thumbnail, size: "30x30"
    end
  end

  def image_link
    content_tag :a,  href: deepLink,  alt:"Book now at #{name}", target: '_blank' do 
        image_tag image, size: "126x182"
    end
  end

  def rating
    "#{confidenceRating}/100"
  end

  def total
    unit = Currency.codes[Expedia.currency_code.upcase.to_sym]
    Utilities.to_currency hotel.total, {precision:2, unit: unit}
  end
end