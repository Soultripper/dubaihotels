class Venere::Importer
  class << self 

    def all
      hotels
    end

    def hotels
      import VenereHotel, 'properties_catalog'
      #TODO: Update geography / nameaddress
    end

    def import(klass, file)

      filename = get_and_store file

      if klass.respond_to? :cols
        sql = "copy #{klass.table_name} (#{klass.cols}) from '#{filename}' delimiter '|' CSV HEADER QUOTE '{' ESCAPE '\';"
      else
        sql = "copy #{klass.table_name} from '#{filename}' delimiter '|' CSV HEADER QUOTE '{' ESCAPE '\';"
      end

      klass.delete_all
      Log.info sql
      ActiveRecord::Base.connection.execute sql
    end

    def get_and_store
      response = get_file
      store_file(response)
    end

    def get_file
      url = "https://catalogs.venere.com/xhi-1.0/XHI_InventoryCatalogue?org=Venere&user=CataloguesTester&psw=T3s73R&filter={'format':'xml,zip'}"
      conn = Faraday.new(url)
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
