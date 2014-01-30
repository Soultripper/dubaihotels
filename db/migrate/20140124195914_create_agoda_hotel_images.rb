class CreateAgodaHotelImages < ActiveRecord::Migration
  def change
    create_table :agoda_hotel_images do |t|
      t.integer :agoda_hotel_id
      t.string :image_url

      t.timestamps
    end
  end
end
