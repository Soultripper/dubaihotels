class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.integer :region_id
      t.string :country_code
      t.string :language_code
      t.string :name
      t.string :region_type
    end
  end
end
