class CreateHotelAttributeLinks < ActiveRecord::Migration
  def change
    create_table :hotel_attribute_links do |t|
      t.integer :ean_hotel_id
      t.integer :attribute_id
      t.string :language_code
      t.text :append_text
    end
  end
end
