class Providers::Etb::Amenity < Providers::Base
  attr_accessible :description, :flag


  def self.cols
    "id, description"   
  end  

end
