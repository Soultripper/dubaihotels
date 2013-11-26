class CreateEtbFacilities < ActiveRecord::Migration
  def change
    create_table :etb_facilities do |t|
      t.text :description
    end
  end
end
