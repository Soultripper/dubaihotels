class AddFlagToHotelAmenities < ActiveRecord::Migration
  def change
    add_column :hotel_amenities, :flag, :integer
  end
end
