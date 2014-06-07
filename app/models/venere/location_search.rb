module Venere
  class LocationSearch < Venere::Search

    attr_reader :location

    DEFAULT_SLICE = 350

    def initialize(location, search_criteria)
      super search_criteria
      @location = location
    end

    def self.by_name(location, search_criteria, options={})
      new(location, search_criteria).by_name(options)
    end

    def self.by_area(location, search_criteria, options={})
      new(location, search_criteria).by_area(options)
    end


    def by_name(options={})
      if !location.city?
        Log.error "Venere location search must be a city. Location: #{location}"
        return
      end

      params = search_params.merge(location_params(options))
      create_list_response Venere::Client.geo_name_search(params)
    end

    def by_area(options={})      
      params = search_params.merge(location_params(options))
      create_list_response Venere::Client.circle_area(params)
    end

    def location_params(options=nil)
      {
        city: location.name,
        country: location.country_name,
        latitude: location.latitude,
        longitude: location.longitude
      }
    end

  end
end
