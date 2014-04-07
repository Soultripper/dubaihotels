class VenereHotel < ActiveRecord::Base
  attr_accessible :address, :breakfast_description, :city, :city_zone, :country, :country_iso_code, :currency_code, :directions, :dyn_property_url, 
                  :geo_id, :hotel_amenities, :hotel_image_url, :hotel_image_url_last_update, :hotel_overview, :hotel_thumb_url, :hotel_thumb_url_last_update, 
                  :hotel_type, :hotel_url_finder_image, :hotel_url_finder_image_last_update, :image_title, :image_url, :image_url_last_update, :last_update, 
                  :latitude, :location_attractions, :location_description, :location_url, :longitude, :name, :place, :price, :property_url, :province, 
                  :rating, :region, :room_amenities, :service_fees, :state, :status, :stay_policy, :thumb_url, :thumb_url_last_update, :user_rating, :zip, :tx_id


  def self.bulk_import(data)
    import data.map {|hotel| new hotel}
    data = nil
  end

end

