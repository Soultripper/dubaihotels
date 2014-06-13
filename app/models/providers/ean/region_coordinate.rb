class Providers::Ean::RegionCoordinate < Providers::Base
  attr_accessible :ean_region_id, :latitude, :longitude, :region_name

  def self.cols
    "ean_region_id, region_name, latitude, longitude"
  end    
  
end
