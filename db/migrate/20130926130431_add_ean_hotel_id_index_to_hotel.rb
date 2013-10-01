class AddEanHotelIdIndexToHotel < ActiveRecord::Migration
  def change
    add_index :hotels, :ean_hotel_id, unique: true      
    add_index :hotels, [:star_rating, :city], unique: false

    add_index :hotel_images, :ean_hotel_id, unique: false        
  end
end
