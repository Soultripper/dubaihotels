module SearchHelper

  def full_path(filter={})
    filters = {
      action: params[:action],
      sort: filter[:sort] || params[:sort],
      start_date: filter[:start_date] || start_date,
      end_date: filter[:end_date] || end_date
    }
    root_path(filters)
  end

  def sort_option(sort, description)
    content_tag :li, data: {link: full_path(sort: sort)}, class: 'sbFocus' do 
      ("Sort By " + content_tag(:span, description, class: 'sort_criterion')).html_safe
    end
  end

end
