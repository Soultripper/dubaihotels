class Location < ActiveRecord::Base
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude  
                   
  attr_accessible :city, :city_id, :country, :country_code, :language_code, :latitude, :longitude, :region, :region_id, :slug, :geog

  def self.all
    @@locations ||= super
  end

  def self.update_slugs
    find_each do |location|
      location.update_attribute :slug, location.create_slug
    end
  end

  def self.regions  
    where('city is null')
  end

  def self.cities
    all.select {|loc| !loc[:city].blank?}
  end

  def self.all_slugs
    @@autocomplete ||= cities.map do |l|
      {
        n: l.to_s,
        s: l.slug
      }
    end
  end

  def point
    geog_before_type_cast
  end

  def self.autocomplete(query)
    return unless query
    query.downcase!
    all_slugs.select {|loc| loc[:n].downcase.start_with? query}
  end


  def to_s
    s = ''
    if city and region 
      s =  "#{city}, #{region}, #{country}" 
    elsif region
      s = "#{region}, #{country}"
    elsif city
      s = "#{city}, #{country}"
    else
      s = country
    end
    s
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
