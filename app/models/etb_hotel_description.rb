class EtbHotelDescription < ActiveRecord::Base
  attr_accessible :description, :etb_hotel_id, :food_and_beverage_description, :important_description, :location_description, :pets_policy, :public_transportation, :teaser

  def self.cols
    "etb_hotel_id, description, important_description, food_and_beverage_description, location_description, public_transportation, pets_policy, teaser"
  end    
  
end
