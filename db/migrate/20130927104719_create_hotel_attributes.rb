class CreateHotelAttributes < ActiveRecord::Migration
  def change
    create_table :hotel_attributes do |t|
      t.integer :attribute_id
      t.string :language_code
      t.string :description
      t.string :attribute_type
      t.string :sub_type
    end
  end
end
