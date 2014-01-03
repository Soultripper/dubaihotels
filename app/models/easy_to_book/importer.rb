class EasyToBook::Importer
  class << self 

    def all
      hotels
      hotel_descriptions
      rooms
      hotel_images      
      hotel_facilities
      hotel_facilities_links
      cities
      points_of_interest
      countries
      provinces
    end

    def hotels
      import EtbHotel, 'hotel-en'
      #TODO: Update geography / nameaddress
    end

    def hotel_descriptions
      import EtbHotelDescription, 'descriptions-en'
    end

    def rooms
      import EtbRoom, 'room-en'
    end

    def hotel_images
      import EtbHotelImage, 'image-en'
    end

    def hotel_facilities
      import EtbFacility, 'facilities_list-en'
    end

    def hotel_facilities_links
      import EtbHotelFacility, 'facilities-en'
    end

    def cities
      import EtbCity, 'city-en'
      #TODO: Update geo
    end

    def points_of_interest
      import EtbPointsOfInterest, 'poi-en'
      #TODO: Update geo
    end

    def countries
      import EtbCountry, 'country-en'
    end

    def provinces
      import EtbProvince, 'province-en'
    end

    def import(klass, file)

      filename = get_and_store file

      if klass.respond_to? :cols
        sql = "copy #{klass.table_name} (#{klass.cols}) from '#{filename}' delimiter ';' CSV HEADER;"
      else
        sql = "copy #{klass.table_name} from '#{filename}' delimiter ';' CSV HEADER;"
      end

      klass.delete_all
      Log.info sql
      ActiveRecord::Base.connection.execute sql
    end

    def get_and_store(file)
      response = get_file(file)
      store_file(response)
    end

    def get_file(file)
      url = "http://www.etbxml.com/static/#{file}.csv.gz"
      conn = Faraday.new(url)
      conn.basic_auth 'hot5hotels', '21efef97'
      conn.get
    end


    def store_file(response)
      tmp_file = Tempfile.new([Time.now.to_i, '.csv'], "#{Rails.root}/tmp")
      tmp_file.binmode
      tmp_file.write response.body
      tmp_file.close
      Log.info "Written temp file #{ tmp_file.path}"
      tmp_file.path
    end
  end
end