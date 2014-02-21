module HotelScopes

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def by_location(location, proximity_in_metres = 20000)

      query = limit(3000)

      if location.city?
        query = query.where("ST_DWithin(hotels.geog, ?, ?) or (city = ? and country_code = ?)", location.point, proximity_in_metres, location.name.downcase, location.country_code.upcase)
      elsif location.landmark? or location.place?
        query = query.where("ST_DWithin(hotels.geog, ?, ?) ", location.point, proximity_in_metres)
      elsif location.region?
        query = query.where("state_province = ?", location.name.downcase)
      elsif location.country?
        query = query.where("country_code = ?", location.country_code.upcase)
      end

      query.order('matches DESC, COALESCE(ranking,0) DESC')
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
    
    def hotel_select_cols
      [
        "id", 
        "star_rating", 
        "geog",
        "user_rating",
        "ranking",
        "ean_hotel_id", 
        "booking_hotel_id", 
        "etb_hotel_id", 
        "agoda_hotel_id", 
        "splendia_hotel_id",
        "laterooms_hotel_id",        
      ]
    end

  end

  def main_image
    image ||= images.find(&:default_image)
    image ? image.url : ''
  end




end