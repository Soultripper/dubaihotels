class CreateEanHotelDescriptions < ActiveRecord::Migration
  def change
    create_table :ean_hotel_descriptions do |t|
      t.integer :ean_hotel_id
      t.string :language_code
      t.text :description
    end
  end
end
