class Expedia::Importer
  

  class << self 
    # require 'zip/zipfilesystem'

    def hotels
      uri = "https://www.ian.com/affiliatecenter/include/V2/ActivePropertyList.zip"
      download_unzip_import_file uri, EanHotel      
    end

    def hotel_descriptions
      uri = "https://www.ian.com/affiliatecenter/include/V2/PropertyDescriptionList.zip"
      download_unzip_import_file uri, EanHotelDescription      
    end

    def hotel_images
      uri = "https://www.ian.com/affiliatecenter/include/V2/HotelImageList.zip"
      download_unzip_import_file uri, EanHotelImage      
    end

    def hotel_rooms
      uri = "https://www.ian.com/affiliatecenter/include/V2/RoomTypeList.zip"
      download_unzip_import_file uri, EanRoomType      
    end

    def hotel_attributes
      uri = "https://www.ian.com/affiliatecenter/include/V2/AttributeList.zip"
      download_unzip_import_file uri, EanHotelAttribute     
    end

    def hotel_attributes_links
      uri = "https://www.ian.com/affiliatecenter/include/V2/PropertyAttributeLink.zip"
      download_unzip_import_file uri, EanHotelAttributeLink     
    end


    # def property_types
    #   uri = "https://www.ian.com/affiliatecenter/include/V2/PropertyTypeList.zip"
    #   # download_unzip_import_file link, EanHotel      
    # end


    def download_unzip_import_file(uri, klass)
      fetch_file URI(uri) do |zipped_file|
        unzip zipped_file do |unzipped_file|
          import_expedia_file klass, unzipped_file
          unzipped_file
        end
      end    
    end

    def fetch_file(url)
      uri = URI(url)
      Net::HTTP.start(uri.host) do |http|
        Log.info "Downloading #{url}"
        yield store_zip_file(http.get(uri.path)) if block_given?
      end
    end

    def store_zip_file(response)
      tmp_file = Tempfile.new([Time.now.to_i, '.zip'])
      tmp_file.binmode
      tmp_file.write response.body
      tmp_file.close
      Log.info "Written temp file #{ tmp_file.path}"
      tmp_file.path
    end


    def unzip(filename)
      Zip::ZipFile.open(filename) do |zipfile|
        zipfile.each do |file|
          path = Tempfile.new([file.name,'.txt']).path
          Log.info "Unzipped #{filename} to #{path}"
          zipfile.extract(file.name, path) {true}
          yield path if block_given?
        end
      end
    end

    # def import_expedia_file(klass, filename)
    #   sql =  "copy #{klass.table_name} (#{klass.cols}) from '#{filename}' with (FORMAT csv, DELIMITER '|', HEADER true, QUOTE '}')"    
    #   Log.info sql
    #   klass.delete_all
    #   ActiveRecord::Base.connection.execute sql
    # end

    def import_expedia_file(klass, filename)

      conn = ActiveRecord::Base.connection_pool.checkout
      raw  = conn.raw_connection

      klass.delete_all

      raw.exec("copy #{klass.table_name} (#{klass.cols}) from STDIN with (FORMAT csv, DELIMITER '|', HEADER true, QUOTE '}')")

      File.readlines(filename).each { |line| raw.put_copy_data line }
      raw.put_copy_end
      while res = raw.get_result do; end # very important to do this after a copy


      ActiveRecord::Base.connection_pool.checkin(conn)
    end


    # def import
    #   EanHotel.joins('left join hotels on hotels.id = ean_hotels.id and hotels.id is null').each do |hotel|
    #     process_exact_origin hotel
    #   end
    #  # post_codes = EanHotel.limit(10).map {|hotel| hotel.postal_code.gsub('-','').gsub(' ','') if hotel.postal_code}.compact
    # end

    # def process_exact_origin(ean_hotel)
    #   matching_hotels = Hotel.within(0.01, origin: ean_hotel)

    #   if matching_hotels.empty?
    #     Log.info "[FAIL] Exact Origin Match #{ean_hotel.id}: No match"
    #     return
    #   end

    #   if matching_hotels.length > 1
    #     Log.info "[FAIL] Exact Origin Match #{ean_hotel.id}: #{matching_hotels.length} matches"
    #     return
    #   end

    #   hotel = matching_hotels[0]  
    #   hotel.update_attribute :ean_hotel_id, ean_hotel.id
    #   Log.info "[SUCCESS[ Exact Origin Match #{ean_hotel.id}: Name[#{hotel.name}, #{ean_hotel.name}], City:[#{hotel.city}, #{ean_hotel.city}]. EAN hotel id updated"
    # end
  end

end