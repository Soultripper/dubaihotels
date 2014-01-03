namespace :expedia do



  desc 'load all expedia'
  task :load_all => :environment do
    import_file EanHotel, 'ActivePropertyList'
    import_file EanHotelDescription, 'PropertyDescriptionList'
    import_file EanHotelImage, 'HotelImageList'
    import_file EanRoomType, 'RoomTypeList'
    import_file EanHotelAttributeLink, 'PropertyAttributeLink'
    import_file EanHotelAttribute, 'AttributeList'
  end

  desc 'load expedia files'
  task :load_hotels => :environment do
    import_file EanHotel, 'ActivePropertyList'
  end

  desc 'load expedia descriptions'
  task :load_descriptions => :environment do
    import_file EanHotelDescription, 'PropertyDescriptionList'
  end

  desc 'load expedia hotel images'
  task :load_images => :environment do
    import_file EanHotelImage, 'HotelImageList'
  end

  desc 'load expedia rooms '
  task :load_rooms => :environment do
    import_file EanRoomType, 'RoomTypeList'
  end

  desc 'load expedia attributes '
  task :load_hotel_attributes => :environment do
    import_file EanHotelAttribute, 'AttributeList'
  end

  desc 'load expedia hotel attributes link '
  task :load_hotel_attributes_links => :environment do
    import_file EanHotelAttributeLink, 'PropertyAttributeLink'
  end
  
  desc 'load regions '
  task :load_regions => :environment do
    import_file EanRegion, 'ParentRegionList'
  end

  desc 'load regions coordinates'
  task :load_region_coordinates => :environment do
    import_file EanRegionCoordinate, 'RegionCenterCoordinatesList'
  end

  desc 'load pof coordinates'
  task :load_pof_coordinates => :environment do
    import_file EanPointsOfInterestCoordinate, 'PointsOfInterestCoordinatesList'
  end

  def import_file(klass, file)

    url = "https://www.ian.com/affiliatecenter/include/V2/#{file}.zip"

    RemoteUnzipper.download_unzip_import_file(url) do |filename|
      if klass.cols
        sql = "copy #{klass.table_name} (#{klass.cols}) from '#{filename}' with (FORMAT csv, DELIMITER '|', HEADER true, QUOTE '}')"    
      else
        sql = "copy #{klass.table_name} from '#{filename}' delimiter '|' CSV HEADER;"
      end

      klass.send :delete_all
      Log.info sql
      ActiveRecord::Base.connection.execute sql
    end


  end



end