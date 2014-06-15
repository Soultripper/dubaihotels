class Providers::Ean::Amenity < Providers::Base
  attr_accessible :attribute_id, :attribute_type, :description, :language_code, :sub_type

  def self.cols
    "attribute_id, language_code, description, attribute_type, sub_type"   
  end  

end
