class Location < ActiveRecord::Base
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude  
                   
  attr_accessible :city, :city_id, :country, :country_code, :language_code, :latitude, :longitude, :region, :region_id, :slug, :geog, :landmark
  # after_save :add_to_soulmate
  # before_destroy :remove_from_soulmate

  # def self.all
  #   @@locations ||= super
  # end

  def self.update_slugs
    find_each do |location|
      location.update_attribute :slug, location.create_slug
    end
  end

  def self.with_slug
    where('slug is not null')
  end

  def self.landmarks
    with_slug.where('landmark is not null')
  end

  def self.regions  
    with_slug.where('city is null and region is not null')
  end

  def self.cities
    with_slug.where('city is not null')
  end

  def self.countries
    with_slug.where('city is null and region is null and country is not null')
  end

  def hotel_ids_for(provider_key, limit=4000)
    Hotel.ids_within_distance_of self, provider_key, limit
  end

  def self.all_slugs
    @@autocomplete ||= cities.map do |l|
      {
        n: l.to_s,
        s: l.slug
      }
    end
  end

  # def self.save_cities_as_json(filename)
  #   File.open(filename, 'w') do |f|
  #     cities.each do |location|
  #       f.puts SoulmateHandler.city_to_soulmate(location)
  #     end
  #   end
  # end


  # def self.save_countries_as_json(filename)
  #   File.open(filename, 'w') do |f|
  #     countries.each do |location|
  #       f.puts SoulmateHandler.country_to_soulmate(location)
  #     end
  #   end
  # end

  def add_to_soulmate
    SoulmateHandler.add_location self
  end

  def remove_from_soulmate
    SoulmateHandler.remove_location self
  end  

  def point
    geog_before_type_cast
  end

  def self.autocomplete(query)
    return unless query
    query.downcase!
    all_slugs.select {|loc| loc[:n].downcase.start_with? query}
  end

  def landmark?
    landmark
  end

  def city?
    landmark.blank? and city
  end

  def region?
    city.blank? and region 
  end

  def country?
    city.blank? and region.blank? and country
  end

  def to_s
    s = ''
    if landmark
      s = "#{landmark}, #{city}"
    elsif city and region 
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

  def title
    if landmark?
      landmark
    elsif city?
      city
    elsif region?
      region
    elsif country?
      country
    else
      to_s
    end
  end

  def create_slug
    s = ''
    if landmark
      s = "#{landmark}"    
    elsif city and region 
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
