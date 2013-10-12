class CreateHotels < ActiveRecord::Migration
  def change
    create_table :hotels do |t|
      t.integer :ean_hotel_id
      t.integer :sequence_number
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state_province
      t.string :postal_code
      t.string :country
      t.float :latitude
      t.float :longitude
      t.string :airport_code
      t.string :property_category
      t.string :property_currency
      t.float :star_rating
      t.integer :confidence
      t.string :supplier_type
      t.string :location
      t.string :chain_code_id
      t.string :region_id
      t.float :high_rate
      t.float :low_rate
      t.string :check_in_time
      t.string :check_out_time
    end
  end
end
