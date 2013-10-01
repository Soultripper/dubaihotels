class CreateHotelImages < ActiveRecord::Migration
  def change
    create_table :hotel_images do |t|
      t.integer :ean_hotel_id
      t.string :caption
      t.string :url
      t.integer :width
      t.integer :height
      t.integer :byte_size
      t.string :thumbnail_url
      t.boolean :default_image
    end
  end
end
