class AddUserRatingToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :user_rating, :float
  end
end
