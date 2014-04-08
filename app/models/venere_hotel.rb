class VenereHotel < ActiveRecord::Base
  attr_accessible :id, :address, :breakfast_description, :city, :city_zone, :country, :country_iso_code, :currency_code, :directions, :dyn_property_url, 
                  :geo_id, :hotel_amenities, :hotel_image_url, :hotel_image_url_last_update, :hotel_overview, :hotel_thumb_url, :hotel_thumb_url_last_update, 
                  :hotel_type, :hotel_url_finder_image, :hotel_url_finder_image_last_update, :image_title, :image_url, :image_url_last_update, :last_update, 
                  :latitude, :location_attractions, :location_description, :location_url, :longitude, :name, :place, :price, :property_url, :province, 
                  :rating, :region, :room_amenities, :service_fees, :state, :status, :stay_policy, :thumb_url, :thumb_url_last_update, :user_rating, :zip, :tx_id


  def self.bulk_import(data)
    import data.map {|hotel| new hotel}
    data = nil
  end

  def self.key_mappings
    {
        lastupdate: :last_update, 
        type: :hotel_type, 
        userrating: :user_rating, 
        currencycode: :currency_code, 
        hotelamenities: :hotel_amenities, 
        roomamenities: :room_amenities, 
        doubleprice: :price, 
        locationdescription: :location_description, 
        locationattractions: :location_attractions, 
        geoid: :geo_id, 
        countryisocode: :country_iso_code, 
        cityzone: :city_zone, 
        hoteloverview: :hotel_overview, 
        staypolicy: :stay_policy, 
        servicefees: :service_fees, 
        breakfastdescription: :breakfast_description, 
        howtoreachdescription: :directions,
        locationurl: :location_url, 
        propertyurl: :property_url, 
        dynpropertyurl: :dyn_property_url, 
        hotelurls_imageurl: :hotel_image_url, 
        hotelurls_imageurl_lastupdate: :hotel_image_url_last_update, 
        hotelurls_thumburl: :hotel_thumb_url, 
        hotelurls_thumburl_lastupdate: :hotel_thumb_url_last_update, 
        hotelurls_finderimageurl: :hotel_url_finder_image, 
        hotelurls_finderimageurl_lastupdate: :hotel_url_finder_image_last_update, 
        imageurl: :image_url, 
        imageurl_lastupdate: :image_url_last_update, 
        thumburl: :thumb_url, 
        thumburl_lastupdate: :thumb_url_last_update

    }
  end


end

