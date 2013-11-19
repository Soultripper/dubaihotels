class AddAgodaHotelIdToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :agoda_hotel_id, :integer
  end
end
