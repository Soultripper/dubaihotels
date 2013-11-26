class AddEtbHotelIdToHotel < ActiveRecord::Migration
  def change
    add_column :hotels, :etb_hotel_id, :integer
  end
end
