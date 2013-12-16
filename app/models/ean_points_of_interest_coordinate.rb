class EanPointsOfInterestCoordinate < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :ean_region_id, :region_name, :region_name_long, :sub_class

  def self.cols
    "ean_region_id, region_name, region_name_long, latitude, longitude, sub_class"
  end    
  
end
