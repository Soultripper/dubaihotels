class Location < ActiveRecord::Base
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude  
                   
  attr_accessible :city, :city_id, :country, :country_code, :language_code, :latitude, :longitude, :region, :region_id, :slug

  def self.update_slugs
    find_each do |location|
      location.update_attribute :slug, location.create_slug
    end
  end

  def self.regions
    where('city is null')
  end

  def create_slug
    s = ''
    if city and region 
      s =  "#{city}-#{region}-#{country}" 
    elsif region
      s = "#{region}-#{country}"
    elsif city
      s = "#{city}-#{country}"
    else
      s = country
    end
    s.gsub('.','').parameterize
  end

end
