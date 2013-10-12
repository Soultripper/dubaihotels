require 'csv'    

namespace :admin do

  Destinations = ['Dubai']


  desc 'Populate Expedia'
  task :populate_expedia => :environment do
    Destinations.each do |dest|
      hotels = Expedia::Client.hotels_by_destination dest     
      Log.info "Found #{hotels.count} Expedia hotels in #{dest}"
      hotels.each_with_index do |h,i| 
        begin
          Log.info "Fetching hotel: #{h['hotelId']}. #{i}/#{hotels.count}"
          Expedia::Hotel.find_or_fetch h['hotelId']
        rescue
          Log.error "Failed to retrieve Expedia hotel: #{h['hotelId']}"
        end
      end
    end
  end

  desc 'populate hotel'
  task :populate_hotels => :environment do
    Hotel.delete_all
    import_expedia_file Hotel, 'ActivePropertyList'
  end

  desc 'populate hotel'
  task :populate_hotel_images => :environment do
    Hotel.delete_all
    import_expedia_file HotelImage, 'HotelImageList'
  end

  desc 'load all expedia'
  task :load_expedia_all => :environment do
    import_expedia_file EanHotel, 'ActivePropertyList'
    import_expedia_file EanHotelImage, 'HotelImageList'
    import_expedia_file EanRoomType, 'RoomTypeList'
    import_expedia_file EanHotelAttributeLink, 'PropertyAttributeLink'
    import_expedia_file EanHotelAttribute, 'AttributeList'
  end

  desc 'load expedia files'
  task :load_expedia_hotels => :environment do
    import_expedia_file EanHotel, 'ActivePropertyList'
  end

  desc 'load expedia hotel images'
  task :load_expedia_images => :environment do
    import_expedia_file EanHotelImage, 'HotelImageList'
  end

  desc 'load expedia rooms '
  task :load_expedia_rooms => :environment do
    import_expedia_file EanRoomType, 'RoomTypeList'
  end

  desc 'load expedia hotel attributes link '
  task :load_expedia_hotel_attributes_links => :environment do
    import_expedia_file EanHotelAttributeLink, 'PropertyAttributeLink'
  end

  desc 'load expedia attributes '
  task :load_expedia_hotel_attributes => :environment do
    import_expedia_file EanHotelAttribute, 'AttributeList'
  end

  def import_expedia_file(klass, filename)
    sql =  "COPY #{klass.table_name} (#{klass.cols}) FROM '#{Rails.root}/tmp/expedia/#{filename}.txt'  WITH (FORMAT csv, DELIMITER '|', HEADER true, QUOTE '}')"    
    ActiveRecord::Base.connection.execute sql
  end

end