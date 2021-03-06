class HotelOrganiser

  attr_reader :hotels, :sort_key, :user_filters, :min_price, :max_price, :prices

  def initialize(hotel_comparisons)
    @hotels = hotel_comparisons
    find_min_price
    find_max_price
    price_values
  end

  def find_min_price
    @min_price ||= round_down price_stats.min 
  end

  def find_max_price 
    @max_price ||= round_up price_stats.max 
  end

  def find_prices
  end


  def round_up(price, nearest=5.0)
    (price.to_f / nearest).ceil * nearest
  end

  def round_down(price, nearest=5.0)
    (price.to_f / nearest).floor * nearest
  end

  def price_stats
    @stats ||= DescriptiveStatistics::Stats.new(hotels.map {|hotel| hotel.offer[:min_price].to_f })
  end

  def price_values
    @price_values ||= hotels.map {|hotel| round_up(hotel.offer[:min_price])}.uniq.sort.select {|p| p >= HotelsConfig.min_price}
  end

  def price_median
    price_stats.median
  end

  def price_mean
    price_stats.mean
  end

  def sort(key)
    @sort_key = key
    Log.debug "Sorting elements by #{@sort_key}"
    case key.to_sym
      when :price; do_sort {|h1| h1.offer[:min_price].to_f}
      when :price_reverse; do_sort {|h1| h1.offer[:min_price].to_f}.reverse!
      when :rating; do_sort {|h1| h1.star_rating.to_f}.reverse!
      when :rating_reverse; do_sort {|h1| h1.star_rating.to_f}
      when :user; do_sort {|h1| [h1.user_rating.to_f, h1.provider_hotel_ranking.to_i]}.reverse!
      when :a_z; do_sort {|h1| h1.name}
      when :distance; do_sort {|h1| h1.distance_from_location.to_f}
      when :distance_reverse; do_sort {|h1| h1.distance_from_location.to_f}.reverse!
      when :saving; do_sort {|h1| h1.offer[:saving].to_f}.reverse!
      # else do_sort { |h1| (h1.star_rating.to_f * 16) + (h1.offer[:saving].to_f) - ((price_mean - h1.offer[:min_price].to_f) / 10).abs}.reverse!
      else do_sort {|h1| [h1.provider_hotel_count, h1.provider_hotel_ranking]}.reverse!
     # else do_sort {|h1|  [h1.ranking.to_f, h1.user_rating.to_f * h1.matches.to_i]}.reverse!
    end
    self
  end

  def do_sort(&block)    
    hotels.sort_by!(&block)
  end

  def filter(filters={})   
    @user_filters = filters

    return false unless apply_filter? filters
    orig_count = hotels.count
    hotels.select! do |hotel|
      filter_min_price(hotel, Utilities.nil_round(filters[:min_price])) and 
      filter_max_price(hotel, Utilities.nil_round(filters[:max_price])) and 
      filter_amenities(hotel, filters[:amenities]) and
      filter_stars(hotel, filters[:star_ratings])
    end
    Log.debug "HotelOrganiser::filter - filtered=#{orig_count - hotels.count}, filters=#{filters}"
  end

  def apply_filter?(filters)
    Utilities.nil_round(filters[:min_price]) != 0 or
    Utilities.nil_round(filters[:max_price]) != 0 or
    filters[:amenities] or 
    filters[:star_ratings]
  end

  def filter_amenities(hotel_comparison, selection)
    return true unless selection

    amenities_mask = HotelAmenity.mask(selection)

    if amenities_mask & 2 == 2
      return false unless hotel_comparison.central?
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

end