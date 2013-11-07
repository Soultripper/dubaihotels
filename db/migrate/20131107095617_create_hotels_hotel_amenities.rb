class CreateHotelsHotelAmenities < ActiveRecord::Migration
  def change
    # create_table :hotels_hotel_amenities do |t|
    #   t.references :hotel
    #   t.references :hotel_amenity
    # end
    add_index :hotels_hotel_amenities, :hotel_id
    add_index :hotels_hotel_amenities, :hotel_amenity_id
  end
end
