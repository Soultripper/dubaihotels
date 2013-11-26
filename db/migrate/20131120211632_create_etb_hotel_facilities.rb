class CreateEtbHotelFacilities < ActiveRecord::Migration
  def change
    create_table :etb_hotel_facilities do |t|
      t.text :services
      t.text :general_facilities
      t.text :extra_common_areas
      t.text :entertainment_facilities
      t.text :business_facilities
      t.text :activities
      t.text :wellness_facilities
      t.text :shops
      t.text :internet
      t.text :internet_connection
      t.text :parking
      t.text :shuttle_service
      t.text :internet_free
      t.text :internet_connection_free
    end
  end
end
