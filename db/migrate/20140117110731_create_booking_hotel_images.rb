class CreateBookingHotelImages < ActiveRecord::Migration
  def change
    create_table :booking_hotel_images do |t|
      t.integer :description_type_id
      t.integer :booking_hotel_id
      t.integer :photo_id
      t.string :url_max_300
      t.string :url_original
      t.string :url_square60
    end
  end
end
