module HotelScopes

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def by_location(location, proximity_in_metres = 20000)

      query = limit(3000).order('coalesce(ranking,0) desc')

      if location.city?
        query = query.where("ST_DWithin(hotels.geog, ?, ?) or lower(city) = ? ", location.point, proximity_in_metres, location.city.downcase)
      elsif location.landmark?
        query = query.where("ST_DWithin(hotels.geog, ?, ?) ", location.point, proximity_in_metres)
      elsif location.region?
        query = query.where("state_province = ?", location.region)
      elsif location.country?
        query = query.where("country_code = ?", location.country_code)
      end

      query
    end


    def ids_within_distance_of(location, provider_key, limit=4000)
      by_location(location).where("#{provider_key} is not null").limit(limit).map &provider_key
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
        "name", 
        "address", 
        "city", 
        "state_province", 
        "postal_code", 
        "country_code", 
        "latitude", 
        "longitude", 
        "star_rating", 
        "ean_hotel_id", 
        "booking_hotel_id", 
        "etb_hotel_id", 
        "agoda_hotel_id", 
        "description", 
        "amenities", 
        "user_rating"
      ]
    end

  end

  def main_image
    image ||= images.find(&:default_image)
    image ? image.url : ''
  end




end