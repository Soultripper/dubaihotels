module SoulmateHandler
  extend self

  def load_locations
    load_cities
    load_regions
    load_countries
    load_landmarks
    load_places
    load_hotels
  end

  def load_hotels
    items = []
    hotel_loader.load(items)
    Hotel.find_each(batch_size: 5000) do |hotel|
      # items << hotel.to_soulmate
      hotel_loader.add hotel.to_soulmate
    end
    # hotel_loader.load(items)
    nil
  end
  
  def add_location(location)
    soulmate = location.to_soulmate
    if location.city?
      city_loader.add(soulmate)
    elsif location.region?
      region_loader.add(soulmate)
    elsif location.country?
      country_loader.add(soulmate)
    elsif location.landmark?
      landmark_loader.add(lsoulmate)  
    elsif location.place?
      place_loader.add(soulmate)     
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
    items = Location.cities.map{|location| location.to_soulmate}
    city_loader.load(items)
  end

  def load_regions    
    items = Location.regions.map{|location| location.to_soulmate}
    region_loader.load(items)
  end

  def load_countries    
    items = Location.countries.map{|location| location.to_soulmate}
    country_loader.load(items)
  end

  def load_landmarks
    items = Location.landmarks.map{|location| location.to_soulmate}
    landmark_loader.load(items)    
  end

  def load_places
    items = Location.places.map{|location| location.to_soulmate}
    place_loader.load(items)    
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

  def place_loader
    loader 'place'
  end

  def hotel_loader
    loader 'hotel'
  end

  def loader(term)
    Soulmate::Loader.new(term)
  end

end