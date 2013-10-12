module SearchHelper

  def full_path(filter={})
    filters = {
      action: params[:action],
      sort: filter[:sort] || params[:sort],
      start_date: filter[:start_date] || start_date,
      end_date: filter[:end_date] || end_date,
      max_stars: filter[:max_stars] || max_stars
    }
    root_path(filters)
  end


  def sort_option(sort, description)
    content_tag :li, data: {link: full_path(sort: sort)}, class: 'sbFocus' do 
      ("Sort By " + content_tag(:span, description, class: 'sort_criterion')).html_safe
    end
  end

  def sort_options
    {
      popularity: 'Popularity',
      rating: 'Rating',
      price: 'Price',
      price_reverse: 'Price Desc',
      proximity: 'Distance',
      a_z: 'A-Z'
    }
  end

  def star_rating(index)
    # <li id="js_boxStars1" class="c_button filter js_box stars stars_1 checked" title="0/ 1 star hotels" data-stars="1"><!-- // --></li>
    checked = index <= max_stars.to_i ? 'checked' : ''
    content_tag :li, '', class: "c_button filter js_box stars stars_#{index} #{checked}", title: "#{index} star hotels", data: {stars: index}
  end

  def current_sort
    sort.to_sym
  end

end
