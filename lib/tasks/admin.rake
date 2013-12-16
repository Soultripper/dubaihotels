require 'csv'    

namespace :admin do

  desc 'load Agoda files'
  task :load_agoda_hotels => :environment do
    import_agoda_file AgodaHotel, 'E342B777-64FD-4A49-9C9F-FEF4BA635863_EN'
  end

  desc 'load ETB files'
  task :load_easy_to_book_hotels => :environment do
    import_easy_to_book_file EtbHotel, 'hotel-en.csv'
  end

  desc 'load ETB hotel iamges'
  task :load_easy_to_book_hotel_images => :environment do
    import_easy_to_book_file EtbHotelImage, 'image-en.csv'
  end



  def import_agoda_file(klass, filename)
    sql =  "copy #{klass.table_name} (#{klass.cols}) from '#{Rails.root}/tmp/agoda/#{filename}.csv' with (FORMAT csv, DELIMITER ',', HEADER true, QUOTE '}')"    
    Log.info sql
    ActiveRecord::Base.connection.execute sql
  end

  def import_easy_to_book_file(klass, filename)
    sql = "copy #{klass.table_name} (#{klass.cols}) from '#{Rails.root}/tmp/easy_to_book/#{filename}.csv' delimiter ';' CSV HEADER;"
    Log.info sql
    ActiveRecord::Base.connection.execute sql
  end

end