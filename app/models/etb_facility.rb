class EtbFacility < ActiveRecord::Base
  attr_accessible :description


  def self.cols
    "id, description"   
  end  

end
