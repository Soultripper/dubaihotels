module HotelScopes

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def by_location(location, proximity_in_metres = 20000)
      where("ST_DWithin(hotels.geog, ?, ?) or city = ? ", location.point, proximity_in_metres, location.city).
      select(["id", "name", "address", "city", "state_province", "postal_code", "country_code", "latitude", "longitude", "star_rating", "ean_hotel_id", "booking_hotel_id", "description", "amenities"])
      # where('city = ? and country_code = ?', location.city, location.country_code)
    end

    def by_star_ratings(min, max)
      (min == 1 and max == 5) ? where(nil) : where(star_rating: min.to_i..max.to_i)
    end

    def with_images
      includes(:images)
    end

  end

  def main_image
    image ||= images.find(&:default_image)
    image ? image.url : ''
  end



end