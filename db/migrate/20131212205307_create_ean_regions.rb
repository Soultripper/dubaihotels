class CreateEanRegions < ActiveRecord::Migration
  def change
    create_table :ean_regions do |t|
      t.integer :region_id
      t.string :region_type
      t.string :relative_significance
      t.string :sub_class
      t.string :region_name
      t.string :region_name_long
      t.integer :parent_region_id
      t.string :parent_region_type
      t.string :parent_region_name
      t.string :parent_region_name_long

    end
  end
end
