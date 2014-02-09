class Agoda::Importer
  class << self 

    def all
      countries
      regions
      cities
      neighbourhoods
      facilities
    end

    def countries
      import AgodaCountry 
    end

    def regions
      import AgodaRegion
    end

    def cities
      import AgodaCity
    end

    def neighbourhoods
      import AgodaNeighbourhood
    end


    def facilities
      import AgodaHotelFacility
    end

    def images
      
    end

    def import(klass)
      klass.delete_all
      klass.import
    end
  end
end