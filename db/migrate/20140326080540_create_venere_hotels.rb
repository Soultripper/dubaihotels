class CreateVenereHotels < ActiveRecord::Migration
  def change
    create_table :venere_hotels do |t|
      t.string :name
      t.string :status
      t.datetime :last_update
      t.string :hotel_type
      t.integer :rating
      t.float :user_rating
      t.string :currency_code
      t.string :hotel_amenities
      t.string :room_amenities
      t.float :price
      t.string :location_description
      t.string :location_attractions
      t.string :geo_id
      t.text :address
      t.string :zip
      t.float :latitude
      t.float :longitude
      t.string :country
      t.string :country_iso_code
      t.string :state
      t.string :region
      t.string :province
      t.string :city
      t.string :place
      t.string :city_zone
      t.text :hotel_overview
      t.text :stay_policy
      t.string :service_fees
      t.text :breakfast_description
      t.text :directions
      t.string :location_url
      t.string :property_url
      t.string :dyn_property_url
      t.string :hotel_image_url
      t.datetime :hotel_image_url_last_update
      t.string :hotel_thumb_url
      t.datetime :hotel_thumb_url_last_update
      t.string :hotel_url_finder_image
      t.datetime :hotel_url_finder_image_last_update
      t.text :image_url
      t.text :image_url_last_update
      t.text :thumb_url
      t.text :thumb_url_last_update
      t.text :image_title
    end
  end
end
