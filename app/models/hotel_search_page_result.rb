class HotelSearchPageResult

  attr_reader :hotels, :search_options, :hotel_organiser

  attr_accessor :user_filters

  def initialize(hotels, search_options={})
    @hotels, @search_options = hotels || [], search_options
    @hotel_organiser = HotelOrganiser.new(hotels)
  end

  def sort(key)
    hotel_organiser.sort key 
    self
  end

  def filter(filters={})   
    primary_hotel = delete_primary_hotel

    if hotel_organiser.filter(filters)
      hotels.insert(0, primary_hotel) if primary_hotel
    end 

    self 
  end

  def delete_primary_hotel    
    hotels.delete(hotels.find {|h| h.slug == location.slug}) if location.hotel?
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

  def as_json(options={})

    matched_hotels = load_hotel_information(options[:hotels]) 
    user_filters = hotel_organiser.user_filters

    # get_rooms matched_hotels

    Jbuilder.encode do |json|
      json.info do
        json.query            location.title
        json.slug             location.slug
        json.channel          search_options[:channel]
        json.key              search_options[:cache_key]
        json.sort             hotel_organiser.sort_key
        json.total_hotels     search_options[:total]
        json.available_hotels hotels.count 
        json.min_price        hotel_organiser.min_price 
        json.max_price        hotel_organiser.max_price  
        json.min_price_filter user_filters[:min_price] if user_filters
        json.max_price_filter user_filters[:max_price] if user_filters  
        json.price_values     hotel_organiser.price_values      
        json.star_ratings     user_filters[:star_ratings] if user_filters
        json.amenities        user_filters[:amenities] if user_filters
        json.longitude        location.longitude
        json.latitude         location.latitude
        json.zoom             location.default_zoom
        json.page_size        HotelsConfig.page_size
        json.timestamp        (search_options[:timestamp] || DateTime.now.utc).to_f
      end      
      json.criteria           search_options[:search_criteria]
      json.state              search_options[:state]

      return if matched_hotels.empty?
      
      if options[:mobile]
        json_for_mobile(json, matched_hotels, user_filters)
      else
        json_for_web(json, matched_hotels, user_filters)
      end
        # json.hotels matched_hotels do |hotel_comparison|
        #   hotel_comparison.hotel.amenities +=2 if hotel_comparison.central? and hotel_comparison.amenities
        #   json.(hotel_comparison.hotel, :id, :name, :address, :city, :state_province, 
        #     :postal_code,  :latitude, :longitude, 
        #     :star_rating, :description, :amenities, :slug)
        #   json.distance       hotel_comparison.distance_from_location || hotel_comparison.distance_from(location)
        #   json.offer          hotel_comparison.offer
        #   json.ratings        hotel_comparison.hotel.ratings
        #   json.main_image     hotel_comparison.hotel, :image_url, :thumbnail_url
        #   json.images         hotel_comparison.hotel.images.limit(5).map &:to_json if options[:include_images]
        #   json.rooms          hotel_comparison.rooms if options[:include_rooms]

        #   # json.score          hotel_comparison.recommended_score
        #   # json.main_image     hotel_comparison.main_image, :url, :thumbnail_url
        #   json.providers(hotel_comparison.provider_deals) {|deal| json.(deal, *(deal.keys - [:rooms])) } unless options[:include_rooms]
        #   json.channel        search_options[:search_criteria].channel_hotel hotel_comparison.id 
        # end
    end
  end 

  def json_for_web(json, hotels, user_filters)
    json.hotels hotels do |hotel_comparison|
      hotel_comparison.hotel.amenities +=2 if hotel_comparison.central? and hotel_comparison.amenities
      json.(hotel_comparison.hotel, :id, :name, :address, :city, :state_province, 
        :postal_code,  :latitude, :longitude, 
        :star_rating, :description, :amenities, :slug)
      json.distance       hotel_comparison.distance_from_location || hotel_comparison.distance_from(location)
      json.offer          hotel_comparison.offer
      json.ratings        hotel_comparison.hotel.ratings
      json.main_image     hotel_comparison.hotel, :image_url, :thumbnail_url
      json.providers(hotel_comparison.provider_deals) {|deal| json.(deal, *(deal.keys - [:rooms])) }
      json.channel        search_options[:search_criteria].channel_hotel hotel_comparison.id 
    end
   end

  def json_for_mobile(json, hotels, user_filters)
    json.hotels hotels do |hotel_comparison|
      hotel_comparison.hotel.amenities +=2 if hotel_comparison.central? and hotel_comparison.amenities
      json.(hotel_comparison.hotel, :id, :name, :address, :city, :state_province, 
        :postal_code,  :latitude, :longitude, 
        :star_rating,  :amenities, :slug)
      json.main_image     hotel_comparison.hotel, :image_url, :thumbnail_url
      json.distance       hotel_comparison.distance_from_location || hotel_comparison.distance_from(location)
      json.offer          hotel_comparison.offer
      json.ratings        hotel_comparison.hotel.ratings
      json.images         hotel_comparison.hotel.images.limit(5).map &:to_json
      json.rooms          hotel_comparison.rooms
      #json.providers(hotel_comparison.provider_deals) {|deal| json.(deal, *(deal.keys - [:rooms])) }
      json.channel        search_options[:search_criteria].channel_hotel hotel_comparison.id 
    end
   end

  def get_rooms(hotels)
    # HotelRoomWorker.perform_async(hotels.map(&:id), search_options[:cache_key])
        # HotelRoomWorker.new.perform(hotels.map(&:id), search_options[:cache_key])

  end

  def as_map_json(options={})

    matched_hotels = load_hotel_information(options[:hotels]) 

    Jbuilder.encode do |json|
      json.state search_options[:state]
      
      if !matched_hotels.empty?
        json.hotels matched_hotels do |hotel_comparison|
          hotel_comparison.hotel.amenities +=2 if hotel_comparison.central? and hotel_comparison.amenities
          json.(hotel_comparison.hotel, :id, :name, :latitude, :longitude, :star_rating,  :slug)
          json.offer          hotel_comparison.offer
          json.main_image     hotel_comparison.hotel, :image_url, :thumbnail_url
          # json.main_image     hotel_comparison.main_image, :url, :thumbnail_url
        end
      end
    end
  end

  def select(count = HotelsConfig.page_size)
    as_json hotels: hotels.take(count)
  end

  def select_for_mobile(count = HotelsConfig.page_size)
    as_json hotels: hotels.take(count), mobile: true
  end

  def select_map_view(count = HotelsConfig.page_size)
    as_map_json hotels: hotels.take(count)
  end

  def page_count(page_no, page_size)
    page_size = check_page_size page_size
    page_index = (page_no-1) * page_size
    (page_index + page_size) > hotels.length ? hotels.length : page_index + page_size
  end

  def load_hotel_information(hotel_comparisons)
    ids = hotel_comparisons.map &:id
    matched_hotels = Hotel.where(id: ids).includes(:provider_hotels)
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