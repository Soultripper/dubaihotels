class HotelSearchPageResult
  attr_reader :hotel_search, :sort_key

  attr_accessor :user_filters

  def initialize(hotel_search, options={})
    @hotel_search = hotel_search
  end

  def as_json(options={})

    matched_hotels = options[:hotels] || hotels
    load_images(matched_hotels)

    Jbuilder.encode do |json|
      json.info do
        json.query            hotel_search.location.city
        json.slug             hotel_search.location.slug
        json.sort             sort_key
        json.total_hotels     hotel_search.total_hotels
        json.available_hotels hotels.count 
        json.min_price        hotel_search.min_price 
        json.max_price        hotel_search.max_price  
        json.min_price_filter user_filters[:min_price] if user_filters
        json.max_price_filter user_filters[:max_price] if user_filters          
      end      
      json.criteria         hotel_search.search_criteria
      json.finished         hotel_search.finished?
      json.hotels matched_hotels do |hotel|
        json.(hotel, :id, :name, :address, :city, :state_province, :postal_code, :country_code, :latitude, :longitude, :star_rating, :description, 
                  :high_rate, :low_rate, :check_in_time, :check_out_time, :property_currency, :ean_hotel_id, :booking_hotel_id, :distance_from_location)
        json.offer          hotel.offer
        json.images         find_images_by(hotel.id), :url, :thumbnail_url, :caption, :width, :height
        json.providers      hotel.provider_deals           
      end
    end
  end

  def find_images_by(hotel_id, count=10)
    hotel_images = @images.find {|k,v| k==hotel_id}
    hotel_images ? hotel_images[1].take(count) : []
  end

  def load_images(filtered_hotels)
    @images ||= HotelImage.where(hotel_id: filtered_hotels.map(&:id)).order('default_image desc').group_by &:hotel_id
  end

  def hotels
    @hotels ||= hotel_search.hotels.clone
  end

  def sort(key)
    @sort_key = key
    case key.to_sym
      # when :popularity; end;
      when :price; do_sort {|h1| h1.offer[:min_price].to_f}
      when :price_reverse; do_sort {|h1| h1.offer[:min_price].to_f}.reverse!
      when :rating; do_sort {|h1| h1.star_rating || 0}.reverse!
      when :rating_reverse; do_sort {|h1| h1.star_rating || 0}
      # when :rating_reverse
      when :a_z; do_sort {|h1| h1.name}
      when :distance; do_sort {|h1| h1.distance_from_location}
      when :distance_reverse; do_sort {|h1| h1.distance_from_location}.reverse!
      # when :postal_code
      else self 
    end
    self
  end

  def filter(filters={})   
    return self unless hotel_search.polled? and hotels
    @user_filters = filters
    Log.debug "#{hotels.count} remaining before #{filters} applied"

    hotels.select! do |hotel|
      filter_price(hotel, filters[:min_price].to_i, filters[:max_price].to_i) and 
      filter_amenities(hotel, filters[:amenities]) and
      filter_stars(hotel, filters[:star_ratings])
    end
    Log.debug "#{hotels.count} remaining aftter #{filters} applied"
    self
  end

  def filter_amenities(hotel, selection)
    return true unless selection
    amenities_mask = HotelAmenity.mask(selection)
    hotel.amenities & amenities_mask == amenities_mask
  end

  def filter_price(hotel, min_price, max_price)
    return true if min_price == 0 and max_price == 0
    hotel.offer[:min_price].between? min_price-1, max_price+1
  end

  def filter_stars(hotel, star_ratings)
    return true unless star_ratings
    star_ratings.map(&:to_i).include? hotel.star_rating.round
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