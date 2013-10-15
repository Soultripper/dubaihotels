class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :area
      t.string :country_code
      t.string :language_code
      t.string :name

      t.timestamps
    end
  end
end
