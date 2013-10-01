class CreateRoomTypes < ActiveRecord::Migration
  def change
    create_table :room_types do |t|
      t.integer :ean_hotel_id
      t.integer :room_type_id
      t.string :language_code
      t.string :image
      t.string :name
      t.text :description
    end
  end
end
