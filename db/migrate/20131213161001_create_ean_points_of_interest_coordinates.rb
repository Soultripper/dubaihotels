class CreateEanPointsOfInterestCoordinates < ActiveRecord::Migration
  def change
    create_table :ean_points_of_interest_coordinates do |t|
      t.integer :ean_region_id
      t.string :region_name
      t.string :region_name_long
      t.float :latitude
      t.float :longitude
      t.string :sub_class
    end
  end
end
