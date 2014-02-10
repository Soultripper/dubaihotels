class EtbFacility < ActiveRecord::Base
  attr_accessible :description, :flag


  def self.cols
    "id, description"   
  end  

end
