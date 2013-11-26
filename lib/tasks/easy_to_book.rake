require 'csv'    

namespace :easy_to_book do



  desc 'load all expedia'
  task :load_expedia_all => :environment do
    import EtbHotel, 'hotel-en'
    import EtbHotelDescription, 'descriptions-en'
    import EtbHotelImage, 'image-en'

    # import EanRoomType, 'RoomTypeList'
    #import_expedia_file EanHotelAttributeLink, 'PropertyAttributeLink'
    # import EanHotelAttribute, 'AttributeList'
  end

  desc 'load ETB hotels'
  task :hotels => :environment do
    import EtbHotel, 'hotel-en'
  end

  desc 'load ETB hotel images'
  task :hotel_images => :environment do
    import EtbHotelImage, 'image-en'
  end

  desc 'load ETB hotel descriptions'
  task :hotel_descriptions => :environment do
    import EtbHotelDescription, 'descriptions-en'
  end

  # desc 'load expedia rooms '
  # task :load_expedia_rooms => :environment do
  #   import EanRoomType, 'RoomTypeList'
  # end

  desc 'load ETB facilities '
  task :hotel_facilities => :environment do
    import EtbFacility, 'facilities_list-en'
  end

  # desc 'load expedia hotel attributes link '
  # task :load_expedia_hotel_attributes_links => :environment do
  #   import EanHotelAttributeLink, 'PropertyAttributeLink'
  # end

  desc 'load ETB Cities '
  task :cities => :environment do
    import EtbCity, 'city-en'
  end

  desc 'load ETB Countries '
  task :countries => :environment do
    import EtbCity, 'country-en'
  end

  def import(klass, filename)
    if klass.cols
      sql = "copy #{klass.table_name} (#{klass.cols}) from '#{Rails.root}/tmp/easy_to_book/#{filename}.csv' delimiter ';' CSV HEADER;"
    else
      sql = "copy #{klass.table_name} from '#{Rails.root}/tmp/easy_to_book/#{filename}.csv' delimiter ';' CSV HEADER;"
    end
    Log.info sql
    ActiveRecord::Base.connection.execute sql
  end

end