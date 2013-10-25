class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :city
      t.integer :city_id
      t.string :region
      t.integer :region_id
      t.string :country
      t.string :country_code
      t.string :language_code
      t.float :longitude
      t.float :latitude
      t.string :slug
    end
  end
end
