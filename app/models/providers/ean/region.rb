class Providers::Ean::Region < Providers::Base
  attr_accessible :parent_region_id, :parent_region_name, :parent_region_name_long, :parent_region_type, :region_id, :region_name, :region_name_long, :region_type, :relative_significance, :sub_class

  def self.cols
    "id, region_type, relative_significance, sub_class, region_name, region_name_long, parent_region_id, parent_region_type, parent_region_name, parent_region_name_long"   
  end  
end
