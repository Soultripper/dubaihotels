class HotelSearchPageResult

  attr_reader :hotels, :sort_key, :search_options

  attr_accessor :user_filters

  def initialize(hotels, search_options={})
    @hotels, @search_options = hotels || [], search_options
    find_min_price
    find_max_price
  end

  def find_min_price
    hotel = hotels.min_by {|h| h.offer[:min_price].to_f}
    @min_price ||= hotel ? hotel.offer[:min_price] : 0
  end

  def find_max_price 
    hotel = hotels.max_by {|h| h.offer[:min_price].to_f}
    @max_price ||= hotel ? hotel.offer[:min_price] : 300
  end

  def sort(key)
    @sort_key = key
    case key.to_sym
      # when :popularity; end;
      when :price; do_sort {|h1| h1.offer[:min_price].to_f}
      when :price_reverse; do_sort {|h1| h1.offer[:min_price].to_f}.reverse!
      when :rating; do_sort {|h1| h1.star_rating.to_f}.reverse!
      when :rating_reverse; do_sort {|h1| h1.star_rating.to_f}
      when :user; do_sort {|h1| [h1.user_rating.to_f, h1.matches.to_i]}.reverse!
      when :a_z; do_sort {|h1| h1.name}
      when :distance; do_sort {|h1| h1.distance_from_location.to_f}
      when :distance_reverse; do_sort {|h1| h1.distance_from_location.to_f}.reverse!
      when :saving; do_sort {|h1| h1.offer[:saving].to_f}.reverse!

      else do_sort {|h1|  [h1.matches, h1.ranking.to_f]}.reverse!
    end
    self
  end


  def do_sort(&block)    
    hotels.sort_by!(&block)
  end

  def filter(filters={})   
    @user_filters = filters


    if filter?(filters)
      searched_hotel = ensure_searched_hotel
      Log.debug "#{hotels.count} hotels remaining before #{filters} applied"
      hotels.select! do |hotel|
        filter_min_price(hotel, Utilities.nil_round(filters[:min_price])) and 
        filter_max_price(hotel, Utilities.nil_round(filters[:max_price])) and 
        filter_amenities(hotel, filters[:amenities]) and
        filter_stars(hotel, filters[:star_ratings])
      end
      hotels.insert(0,searched_hotel) if !ensure_searched_hotel and searched_hotel
      Log.debug "#{hotels.count} hotels remaining after #{filters} applied"
    else
      Log.debug "#{hotels.count} hotels found - no filters applied"
    end

    self
  end

  def ensure_searched_hotel    
    hotels.find {|h| h.slug == location.slug} if location.hotel?
  end

  def filter?(filters)
    Utilities.nil_round(filters[:min_price]) != 0 or
    Utilities.nil_round(filters[:max_price]) != 0 or
    filters[:amenities] or 
    filters[:star_ratings]
  end

  def filter_amenities(hotel_comparison, selection)
    return true unless selection

    amenities_mask = HotelAmenity.mask(selection)

    if amenities_mask & 2 == 2
      return false unless hotel_comparison.central?(location)
      amenities_mask -= 2
    end

    hotel_comparison.amenities & amenities_mask == amenities_mask
  end

  def filter_min_price(hotel, price)
    return true if price == 0
    Utilities.nil_round(hotel.offer[:min_price]) > price-1
  end

  def filter_max_price(hotel, price)
    return true if price == 0
    Utilities.nil_round(hotel.offer[:min_price]) < price+1
  end  

  def filter_stars(hotel, star_ratings)
    return true unless star_ratings
    star_ratings.map(&:to_i).include? hotel.star_rating.to_f.round
  end

  def paginate(page_no, page_size)
    page_size = check_page_size page_size
    page_index = (page_no-1) * page_size
    lower = page_index < 0 ? 0 : page_index
    upper = (page_index + page_size) > hotels.length ? hotels.length : page_index + page_size

    if lower > upper
      as_json hotels: []
    else
      as_json hotels: hotels[lower...upper]
    end
  end

  def check_page_size(value)
    return HotelsConfig.max_page_size if value > HotelsConfig.max_page_size
    return HotelsConfig.min_page_size if value < HotelsConfig.min_page_size
    value
  end

  def location
    search_options[:location]
  end

  # def find_images_by(hotel, count=10)
  #   hotel_images = @images.find {|k,v| k==hotel.id}
  #   hotel_images ? hotel_images[1].take(count) : []
  # end



  def as_json(options={})

    matched_hotels = load_hotel_information(options[:hotels]) 

    Jbuilder.encode do |json|
      json.info do
        json.query            location.title
        json.slug             location.slug
        json.channel          search_options[:channel]
        json.sort             sort_key
        json.total_hotels     search_options[:total]
        json.available_hotels hotels.count 
        json.min_price        @min_price 
        json.max_price        @max_price  
        json.min_price_filter user_filters[:min_price] if user_filters
        json.max_price_filter user_filters[:max_price] if user_filters          
        json.star_ratings     user_filters[:star_ratings] if user_filters
        json.amenities        user_filters[:amenities] if user_filters
        json.longitude        location.longitude
        json.latitude         location.latitude
        json.zoom             location.default_zoom
        json.page_size        HotelsConfig.page_size
      end      
      json.criteria           search_options[:search_criteria]
      json.state              search_options[:state]

      if !matched_hotels.empty?
        json.hotels matched_hotels do |hotel_comparison|
          hotel_comparison.hotel.amenities +=2 if hotel_comparison.central?(location) and hotel_comparison.amenities
          json.(hotel_comparison.hotel, :id, :name, :address, :city, :state_province, 
            :postal_code,  :latitude, :longitude, 
            :star_rating, :description, :amenities, :slug)
          json.rooms          hotel_comparison.rooms
          json.offer          hotel_comparison.offer
          json.ratings        hotel_comparison.hotel.ratings
          json.images         find_images_by(hotel_comparison.hotel), :url, :thumbnail_url, :caption, :width, :height
          json.providers      hotel_comparison.provider_deals
          json.channel        search_options[:search_criteria].channel_hotel hotel_comparison.id 
        end
      end
    end
  end

  def as_map_json(options={})

    matched_hotels = load_hotel_information(options[:hotels]) 

    Jbuilder.encode do |json|
      json.state search_options[:state]
      
      if !matched_hotels.empty?
        json.hotels matched_hotels do |hotel_comparison|
          hotel_comparison.hotel.amenities +=2 if hotel_comparison.central?(location) and hotel_comparison.amenities
          json.(hotel_comparison.hotel, :id, :name, :latitude, :longitude, :star_rating,  :slug)
          json.offer          hotel_comparison.offer
          json.images         hotel_comparison.hotel, :url, :thumbnail_url
        end
      end
    end
  end

  def select(count = HotelsConfig.page_size)
    as_json hotels: hotels.take(count)
  end


  def select_map_view(count = HotelsConfig.page_size)
    as_map_json hotels: hotels.take(count)
  end

  # def take(page_no, page_size)
  #   count = page_count(page_no, page_size)
  #   as_json hotels: hotels.take(count)
  # end

  def page_count(page_no, page_size)
    page_size = check_page_size page_size
    page_index = (page_no-1) * page_size
    (page_index + page_size) > hotels.length ? hotels.length : page_index + page_size
  end

  def find_images_by(hotel, count=11)
    hotel.images.limit(count) || []
  end

  def hotel_images(hotel)
    hotel.images
  end

  def load_images(filtered_hotels)
    @images ||= HotelImage.where(hotel_id: filtered_hotels.map(&:id)).order('default_image desc').group_by &:hotel_id
  end

  def load_hotel_information(hotel_comparisons)
    ids = hotel_comparisons.map &:id
    # matched_hotels = Hotel.with_images.where(id: ids).to_a
    matched_hotels = Hotel.where(id: ids).to_a
    matched_hotels.each do |hotel|
      begin
        hotel_comparison =  hotel_comparisons.find {|hc| hc.id==hotel.id}
        hotel_comparison.hotel = hotel
      rescue Excpetion => msg 
        Log.error "Unable to set hotel offer for hotel comparison: #{hotel_comparison}. Msg: #{msg}"
      end
    end
    hotel_comparisons
  end


end