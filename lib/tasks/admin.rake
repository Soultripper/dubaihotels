require 'csv'    

namespace :admin do

  desc 'load Agoda files'
  task :load_agoda_hotels => :environment do
    import_agoda_file AgodaHotel, 'E342B777-64FD-4A49-9C9F-FEF4BA635863_EN'
  end

  desc 'load all expedia'
  task :load_expedia_all => :environment do
    import_expedia_file EanHotel, 'ActivePropertyList'
    import_expedia_file EanHotelDescription, 'PropertyDescriptionList'
    import_expedia_file EanHotelImage, 'HotelImageList'
    import_expedia_file EanRoomType, 'RoomTypeList'
    #import_expedia_file EanHotelAttributeLink, 'PropertyAttributeLink'
    import_expedia_file EanHotelAttribute, 'AttributeList'
  end

  desc 'load expedia files'
  task :load_expedia_hotels => :environment do
    import_expedia_file EanHotel, 'ActivePropertyList'
  end

  desc 'load expedia descriptions'
  task :load_expedia_descriptions => :environment do
    import_expedia_file EanHotelDescription, 'PropertyDescriptionList'
  end

  desc 'load expedia hotel images'
  task :load_expedia_images => :environment do
    import_expedia_file EanHotelImage, 'HotelImageList'
  end

  desc 'load expedia rooms '
  task :load_expedia_rooms => :environment do
    import_expedia_file EanRoomType, 'RoomTypeList'
  end

  desc 'load expedia attributes '
  task :load_expedia_hotel_attributes => :environment do
    import_expedia_file EanHotelAttribute, 'AttributeList'
  end

  desc 'load expedia hotel attributes link '
  task :load_expedia_hotel_attributes_links => :environment do
    import_expedia_file EanHotelAttributeLink, 'PropertyAttributeLink'
  end


  def import_expedia_file(klass, filename)
    sql =  "copy #{klass.table_name} (#{klass.cols}) from '#{Rails.root}/tmp/expedia/#{filename}.txt' with (FORMAT csv, DELIMITER '|', HEADER true, QUOTE '}')"    
    Log.info sql
    ActiveRecord::Base.connection.execute sql
  end


  def import_agoda_file(klass, filename)
    sql =  "copy #{klass.table_name} (#{klass.cols}) from '#{Rails.root}/tmp/agoda/#{filename}.csv' with (FORMAT csv, DELIMITER ',', HEADER true, QUOTE '}')"    
    Log.info sql
    ActiveRecord::Base.connection.execute sql
  end

end