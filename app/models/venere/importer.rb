require 'zipruby'
require 'fileutils'

class Venere::Importer
  class << self 

    def all
      hotels
    end

    def hotels
      import VenereHotel
      #TODO: Update geography / nameaddress
    end

    def import(klass, filename=nil)

      filename = get_and_store unless filename
      filename = unzip filename

      if klass.respond_to? :cols
        sql = "copy #{klass.table_name} (#{klass.cols}) from '#{filename}' delimiter '|' CSV HEADER QUOTE '{' ESCAPE '^';"
      else
        sql = "copy #{klass.table_name} from '#{filename}' delimiter '|' CSV HEADER QUOTE '{' ESCAPE '^';"
      end


      klass.delete_all
      Log.debug "Deleted all #{klass} records"
      Log.info sql
      ActiveRecord::Base.connection.execute sql
    end

    def get_and_store
      response = get_file
      store_file(response)
    end

    def unzip(filename)

      Log.debug "Unzipping #{filename}....."
      path = ''
      Zip::Archive.open(filename) do |ar|
        ar.each do |zf|
          path = Tempfile.new(zf.name).path
          open(path, 'wb') do |f|
            f << zf.read
          end
        end
      end
      Log.debug "Unzipped #{filename} to #{path}"
      path
    end

    def get_file

      conn = Faraday.new(url)
      conn.get
    end

    def url
      filter = CGI.escape("{'format':'xml.zip'}")
      "https://catalogs.venere.com/xhi-1.0/XHI_InventoryCatalogue?org=Venere&user=CataloguesTester&psw=T3s73R&filter=" + filter
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
