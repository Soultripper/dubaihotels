#!/bin/env ruby
# encoding: utf-8
module AppHelper

  def city_link(city)
    content_tag :li do
      link_to city[1], city[0], target: '_self'
    end
  end

  def display_star_rating(index, hotel_star_rating)
    hotel_star_rating = hotel_star_rating.to_f
    if hotel_star_rating > index and hotel_star_rating < index+1
      content_tag(:i, nil, class: "fa fa-star-half-empty") 
    elsif hotel_star_rating > index
      content_tag(:i, nil, class: "fa fa-star") 
    else
      content_tag(:i, nil, class: "fa fa-star-o") 
    end
  end

  def logo(name, desc)
    image_tag "logos/#{name}",  alt: desc
  end

  def hotel_image_src(hotel_image)
    hotel_image  ? hotel_image.url : 'http://d1pa4et5htdsls.cloudfront.net/images/61/2025/68208/68208-rev1-img1-400.jpg'
  end

  def currency_flag_icon_by(currency_code)
    country_code = currency_code[0]
    values = currency_code[1]
    currency = values[0]
    currency_symbol = values[1]

    image_tag("icons/flags/#{country_code.downcase}.png", alt: country_code) << " #{currency} (#{currency_symbol})"
  end


end
