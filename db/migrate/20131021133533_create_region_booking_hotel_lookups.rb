class CreateRegionBookingHotelLookups < ActiveRecord::Migration
  def change
    create_table :region_booking_hotel_lookups do |t|
      t.integer :region_id
      t.integer :booking_hotel_id

      t.timestamps
    end
  end
end
