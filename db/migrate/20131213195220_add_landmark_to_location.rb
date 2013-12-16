class AddLandmarkToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :landmark, :string
  end
end
