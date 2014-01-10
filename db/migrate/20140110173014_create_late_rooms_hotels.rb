class CreateLateRoomsHotels < ActiveRecord::Migration
  def change
    create_table :late_rooms_hotels do |t|
      t.string :name
      t.string :star_rating
      t.text :address1
      t.string :city
      t.string :county
      t.string :postcode
      t.string :country
      t.string :country_iso
      t.text :description
      t.text :directions
      t.string :image
      t.text :images
      t.float :longitude
      t.float :latitude
      t.String :url
      t.string :price_from
      t.string :max_price
      t.string :currency_code
      t.string :score_out_of_6
      t.string :no_of_reviews
      t.string :review_url
      t.text :facilities
      t.string :accommodation_type
      t.text :appeals
      t.string :star_accreditor
      t.string :created_date
      t.string :total_rooms
      t.text :cancellation_policy
      t.string :cancellation_days
      t.text :cancellation_terms
      t.string :city_tax_type
      t.string :city_tax_value
      t.string :city_tax_opted_in
      t.string :is_city_tax_area
      t.string :check_in_time
      t.string :check_out_time
      t.string :latest_check_in_time
    end
  end
end
