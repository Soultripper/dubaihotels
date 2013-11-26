class CreateEtbCountries < ActiveRecord::Migration
  def change
    create_table :etb_countries do |t|
      t.string :country_name
      t.string :country_iso
      t.string :url
    end
  end
end
