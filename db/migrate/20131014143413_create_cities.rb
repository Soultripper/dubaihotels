class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :country_code
      t.string :language_code
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :timezone_name
      t.string :timezone_offset

      t.timestamps
    end
  end
end
