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


end
