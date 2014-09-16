class HotelView

  attr_reader :hotel, :search_criteria

  def initialize(hotel, search_criteria)
    @hotel, @search_criteria = hotel, search_criteria
  end

  def ratings
  end


  def as_json(options={})
    Jbuilder.encode do |json|
      json.criteria search_criteria

      json.hotel do 
        json.(hotel, :id, :name, :address, :city, :state_province, :postal_code, :user_rating, :latitude, :longitude, :star_rating, :description_clean, :amenities, :slug)
        json.ratings        hotel.ratings
        json.rooms          options[:rooms]
        json.images         hotel.images.limit(10), :url, :thumbnail_url, :width, :height
        json.channel        search_criteria.channel_hotel hotel.id 
        json.key            options[:key]
        json.providers      hotel.providers_to_json if options[:include_providers]
      end
      
    end

  end
end
