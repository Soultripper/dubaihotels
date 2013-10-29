class HotelSearchPageResult
  attr_reader :hotel_search, :sort_key

  def initialize(hotel_search, options={})
    @hotel_search = hotel_search
  end

  def as_json(options={})
    Log.info "#{hotel_search.available_hotels}"
    loaded_hotels = options[:hotels] || hotels

    Jbuilder.encode do |json|
      json.query            hotel_search.location.city
      json.criteria         hotel_search.search_criteria
      json.sort             sort_key
      json.total_hotels     hotel_search.total_hotels
      json.available_hotels hotel_search.available_hotels
      json.finished         hotel_search.finished?
      json.hotels loaded_hotels do |hotel|
        json.(hotel, :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, :description, 
                  :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id, :distance_from_location)
        json.offer          hotel.offer
        json.images         hotel.images.take(10), :url, :thumbnail_url, :caption, :width, :height
        json.providers      hotel.provider_deals           
      end
    end
  end

  def hotels
    hotel_search.hotels
  end

  def sort(key)
    @sort_key = key
    case key.to_sym
      # when :popularity; end;
      when :price; do_sort {|h1| h1.offer[:min_price].to_f}
      when :price_reverse; do_sort {|h1| h1.offer[:min_price].to_f}.reverse!
      when :rating; do_sort {|h1| h1.star_rating}.reverse!
      when :rating_reverse; do_sort {|h1| h1.star_rating}
      # when :rating_reverse
      when :a_z; do_sort {|h1| h1.name}
      when :distance; do_sort {|h1| h1.distance_from_location}
      when :distance_reverse; do_sort {|h1| h1.distance_from_location}.reverse!
      # when :postal_code
      else self 
    end
    self
  end

  def paginate(page_no, page_size)
    page_size = check_page_size page_size
    page_index = (page_no-1) * page_size
    lower = page_index < 0 ? 0 : page_index
    upper = (page_index + page_size) > hotels.length ? hotels.length : page_index + page_size
    as_json hotels: hotels[lower...upper]
  end

  def check_page_size(value)
    return HotelsConfig.max_page_size if value > HotelsConfig.max_page_size
    return HotelsConfig.min_page_size if value < HotelsConfig.min_page_size
    value
  end

  def do_sort(&block)
    hotels.sort_by!(&block) if hotels
  end
end