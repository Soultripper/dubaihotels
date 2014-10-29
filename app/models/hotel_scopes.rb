module HotelScopes

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def by_location(location, proximity_in_metres = 8000)

      limit = location.hotel_limit || 500
      my_location_limit = 150
      distance_limit = 300
      query = limit(limit)

      if location.city?
        query = query.where("ST_DWithin(hotels.geog, ?, ?) or (lower(city)= ? and country_code = ?)", location.point, proximity_in_metres, location.name.downcase, location.country_code.downcase)
      elsif location.my_location?
        return query.where("ST_DWithin(hotels.geog, ST_MakePoint(?,?), ?) ", location.longitude, location.latitude, 3000).
               order("ST_Distance(hotels.geog, ST_MakePoint(#{location.longitude}, #{location.latitude})), COALESCE(provider_hotel_ranking,0) DESC, user_rating DESC").limit(my_location_limit)
      elsif location.distance_based?
        return query.where("ST_DWithin(hotels.geog, ?, ?) ", location.point, 3000).order("ST_Distance(hotels.geog, '#{location.geog}'), COALESCE(provider_hotel_ranking,0) DESC, user_rating DESC").limit(distance_limit)
      elsif location.region?
        query = query.where("lower(state_province) = ?", location.name.downcase)
      elsif location.country?
        query = query.where("country_code = ?", location.country_code.downcase)
      end

      query.order('provider_hotel_count desc, COALESCE(provider_hotel_ranking,0) DESC, user_rating DESC')
    end

    def ids_within_distance_of(location, provider_key, limit=4000)
      by_location(location).where("#{provider_key} IS NOT NULL").limit(limit).map &provider_key
    end

    def by_star_ratings(min, max)
      (min == 1 and max == 5) ? where(nil) : where(star_rating: min.to_i..max.to_i)
    end

    def with_images
      includes(:images)
    end

    def with_provider(ids)
      where(id: ids).includes(:provider_hotels).order('provider_hotel_count desc, COALESCE(provider_hotel_ranking,0) DESC, user_rating DESC')
    end
    

    def by_location_slug(slug)
      loc = Location.find_by_slug slug
      by_location loc
    end


  end

  def main_image
    image ||= images.find(&:default_image)
    image ? image.url : ''
  end




end