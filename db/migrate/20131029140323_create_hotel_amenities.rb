class CreateHotelAmenities < ActiveRecord::Migration
  def change
    create_table :hotel_amenities do |t|
      t.string :name
      t.integer :value
    end
  end
end
