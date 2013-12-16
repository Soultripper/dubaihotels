class CreateBookingRegionHotels < ActiveRecord::Migration
  def change
    create_table :booking_region_hotels do |t|
      t.integer :booking_hotel_id
      t.integer :booking_region_id

      t.timestamps
    end
  end
end
