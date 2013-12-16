class AddRankingToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :ranking, :float
  end
end
