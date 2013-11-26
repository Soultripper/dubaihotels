class AddEtbCityIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :etb_city_id, :integer
  end
end
