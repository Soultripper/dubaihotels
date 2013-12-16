class CreateEanRegionCoordinates < ActiveRecord::Migration
  def change
    create_table :ean_region_coordinates do |t|
      t.integer :ean_region_id
      t.string :region_name
      t.float :latitude
      t.float :longitude
    end
  end
end
