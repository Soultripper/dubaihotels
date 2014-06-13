class Providers::Splendia::Amenity < Providers::Base
  attr_accessible :description, :flag


  def self.cols
    "id, description"   
  end  

end
