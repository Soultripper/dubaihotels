module SoulmateHandler
  extend self

  def add_location(location)
    if location.city?
      city_loader.add(city_to_soulmate(location))
    elsif location.region?
      region_loader.add(region_to_soulmate(location))
    elsif location.country?
      country_loader.add(country_to_soulmate(location))
    elsif location.landmark?
      landmark_loader.add(landmark_to_soulmate(location))      
    end
  end

  def remove_location(location)
    if location.city?
      city_loader.remove("id" => location.id)
    elsif location.region?
      region_loader.remove("id" => location.id)
    elsif location.country?
      country_loader.remove("id" => location.id)
    elsif location.landmark?
      landmark_loader.remove("id" => location.id)      
    end
  end

  def load_cities    
    items = Location.cities.map{|location| city_to_soulmate(location)}
    city_loader.load(items)
  end

  def load_regions    
    items = Location.regions.map{|location| region_to_soulmate(location)}
    region_loader.load(items)
  end

  def load_countries    
    items = Location.countries.map{|location| country_to_soulmate(location)}
    country_loader.load(items)
  end

  def load_landmarks
    items = Location.landmarks.map{|location| landmark_to_soulmate(location)}
    landmark_loader.load(items)    
  end

  def city_loader
    loader 'city'
  end

  def region_loader
    loader 'region'
  end

  def country_loader
    loader 'country'
  end

  def landmark_loader
    loader 'landmark'
  end

  def loader(term)
    Soulmate::Loader.new(term)
  end

  def city_to_soulmate(location)
    {
      id: location.id,
      term: location.city,
      score: 250 - location.slug.length,
      data:{
        slug: location.slug,
        title: location.to_s
      }
    }.as_json
  end

  def region_to_soulmate(location)
    {
      id: location.id,
      term: location.region,
      score: 250 - location.slug.length,
      data:{
        slug: location.slug,
        title: location.to_s
      }
    }.as_json
  end

  def country_to_soulmate(location)
    {
      id: location.id,
      term: location.country,
      score: 250 - location.slug.length,
      data:{
        slug: location.slug,
        title: location.to_s
      }
    }.as_json
  end


  def landmark_to_soulmate(location)
    {
      id: location.id,
      term: location.landmark,
      score: 250 - location.slug.length,
      data:{
        slug: location.slug,
        title: location.to_s
      }
    }.as_json
  end


end