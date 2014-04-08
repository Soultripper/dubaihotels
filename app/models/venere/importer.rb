require 'zipruby'
require 'fileutils'
require 'smarter_csv'

class Venere::Importer
  class << self 

    CSV_OPTIONS = {
      col_sep: '|',
      quote_char: '{',
      chunk_size: 100,
      key_mapping: VenereHotel.key_mappings
    }

    def all
      hotels
    end

    def hotels
      import VenereHotel
      #TODO: Update geography / nameaddress
    end

    # def import(klass, filename=nil)

    #   filename = get_and_store unless filename
    #   filename = unzip filename

    #   sql = sql_for klass

    #   klass.delete_all
    #   Log.debug "Deleted all #{klass} records"
    #   Log.info sql
    #   ActiveRecord::Base.connection.execute sql
    # end

    # def import(klass, filename=nil)

    #   filename = get_and_store unless filename
    #   filename = unzip filename

    #   data = File.open(filename) {|f| f.read }

    #   klass.delete_all
    #   Log.debug "Deleted all #{klass} records"

    #   conn = ActiveRecord::Base.connection_pool.checkout
    #   raw  = conn.raw_connection
    #   raw.exec(sql_for(klass))
    #   data.each_line {|line| raw.put_copy_data(line) }
    #   raw.put_copy_end

    #   while res = raw.get_result do; end # very important to do this after a copy
    #   ActiveRecord::Base.connection_pool.checkin(conn)
    #   data = nil
    #   filename
    # end

    def sql_for(klass)
      if klass.respond_to? :cols
         return "COPY #{klass.table_name} FROM STDIN DELIMITER '|' CSV HEADER QUOTE '{' ESCAPE '^';"
      end
        # return "copy #{klass.table_name} (#{klass.cols}) from '#{filename}' delimiter '|' CSV HEADER QUOTE '{' ESCAPE '^';" 
      # "copy #{klass.table_name} from '#{filename}' delimiter '|' CSV HEADER QUOTE '{' ESCAPE '^';"
      "COPY #{klass.table_name} FROM STDIN DELIMITER '|' CSV HEADER QUOTE '{' ESCAPE '^';"
    end


    def import(klass, filename)

      n = SmarterCSV.process(filename, CSV_OPTIONS) do |chunk|
            # we're passing a block in, to process each resulting hash / row (block takes array of hashes)
            # when chunking is enabled, there are up to :chunk_size hashes in each chunk
          VenereHotel.bulk_import chunk
      end
    end

    # def self.up
    #   c = Property.connection.raw_connection
    #   c.exec(%q{COPY cities (city, state_id, lat, long) FROM STDIN})
    #   data = File.open(File.dirname(__FILE__) + '/places_cities.pgdump') {|f| f.read }
    #   data.each_line {|line| c.putline(line) }
    #   c.endcopy
    # end

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
      Log.debug "Downloading file at #{url}"
      conn = Faraday.new(url)
      conn.get
    end

    def url
      filter = CGI.escape("{'format':'xml.zip'}")
      "https://catalogs.venere.com/xhi-1.0/XHI_InventoryCatalogue?org=Venere&user=CataloguesTester&psw=T3s73R&filter=" + filter
    end


    # def store_file(response)
    #   tmp_file = Tempfile.new([Time.now.to_i, '.zip'], "#{Rails.root}/tmp")
    #   tmp_file.binmode
    #   tmp_file.write response.body
    #   tmp_file.close
    #   Log.info "Written temp file #{ tmp_file.path}"
    #   response = nil
    #   tmp_file.path
    # end

    def store_file(response)
      tmp_file = Tempfile.new([Time.now.to_i, '.zip'], "#{Rails.root}/tmp")
      tmp_file.binmode
      tmp_file.write response.body
      tmp_file.close
      Log.info "Written temp file #{ tmp_file.path}"
      response = nil
      tmp_file = nil
      tmp_file.path
    end

    def upload_file(filename)
      uploader = HotelCatalogUploader.new
      uploader.store! File.open(filename)
    end

  end
end
