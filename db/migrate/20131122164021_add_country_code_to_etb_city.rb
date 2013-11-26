class AddCountryCodeToEtbCity < ActiveRecord::Migration
  def change
    add_column :etb_cities, :country_code, :string
  end
end
