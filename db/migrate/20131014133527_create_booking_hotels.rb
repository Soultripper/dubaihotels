class CreateBookingHotels < ActiveRecord::Migration
  def change
    create_table :booking_hotels do |t|
      t.string :district
      t.integer :nr_rooms
      t.string :city
      t.string :check_in_to
      t.string :check_in_from
      t.float :minrate
      t.string :url
      t.integer :review_nr
      t.string :address
      t.float :commission
      t.integer :ranking
      t.integer :city_id
      t.string :review_score      
      t.float :longitude
      t.float :latitude
      t.integer :max_rooms_in_reservation
      t.integer :max_persons_in_reservation
      t.string :name
      t.integer :hoteltype_id
      t.boolean :preferred
      t.string :country_code
      t.boolean :class_is_estimated
      t.boolean :is_closed
      t.string :check_out_to
      t.string :check_out_from
      t.string :zip
      t.string :contractchain_id
      t.float :maxrate
      t.integer :classification
      t.string :languagecode
      t.string :currencycode
    end
  end
end
