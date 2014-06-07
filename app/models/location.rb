class Location < ActiveRecord::Base
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude  
                   
  attr_accessible :name, :location_type, :description, :longitude, :latitude, :slug, :country_code, :score, :geog

  attr_accessor :hotel_limit

  # after_save :add_to_soulmate
  # before_destroy :remove_from_soulmate

  # def self.all
  #   @@locations ||= super
  # end

  # def self.update_slugs
  #   find_each do |location|
  #     location.update_attribute :slug, location.slug
  #   end
  # end

  def self.with_slug
    where('slug is not null')
  end

  def self.landmarks
    with_slug.where(location_type: 'Point of Interest')
  end

  def self.places  
    with_slug.where(location_type: ['Neighborhood', 'Place'])
  end

  def self.regions  
    with_slug.where(location_type: 'Region')
  end

  def self.cities
    with_slug.where(location_type: 'City')
  end

  def self.countries
    with_slug.where(location_type: 'Country')
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

  def self.determine_scores
    where('geog is not null and score is null').find_each do |location|
      begin
        location.update_attribute :score, Hotel.by_location(location).limit(nil).count
        nil
      rescue => msg
        nil
      end
    end
  end

  def self.my_location(latitude, longitude)
    Location.new name: 'My location', longitude: longitude, latitude: latitude, slug:"my-location", location_type: 'MyLocation', description: 'My Location'
  end


  def unique_id
    return "my-location-#{longitude}-#{latitude}" if my_location?
    slug
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


  def distance_based?
    landmark? or place? or hotel? or my_location?
  end

  def my_location?
    location_type == 'MyLocation'
  end

  def landmark?
    location_type == 'Point of Interest'
  end

  def city?
    location_type == 'City'
  end

  def country_name
    return name if country?
    cc = CountryCode.where(iso2: country_code.upcase).first
    cc.name if cc
  end


  def region?
    location_type == 'Region'
    # ['Region', 'Province (State)'].include? location_type
  end

  def place?
    ['Neighborhood', 'Place'].include? location_type
  end

  def country?
    location_type == 'Country'
  end

  def hotel?
    location_type == 'Hotel'
  end

  def default_zoom
    if distance_based?
      return 13
    elsif hotel?
      return 14
    else
      return 10
    end
  end


  def to_s
    description
  end

  def title
    name
  end

  # def create_slug
  #   s = ''
  #   if landmark
  #     s = "#{landmark}"    
  #   elsif city and region 
  #     s =  "#{city}-#{region}-#{country}" 
  #   elsif region
  #     s = "#{region}-#{country}"
  #   elsif city
  #     s = "#{city}-#{country}"
  #   else
  #     s = country
  #   end
  #   s.gsub('.','').parameterize
  # end

  def to_soulmate
    {
      id: id,
      term: name,
      score: score,
      data:{
        slug: slug,
        title: description
      }
    }.as_json
  end

  def as_json
    {
      id: id, 
      name: name,
      location_type: location_type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      slug: slug,
      country_code: country_code
    }
  end

  # def self.insert_hotels
  #   where(location_type: 'Hotel').delete_all
    
  # end



end
