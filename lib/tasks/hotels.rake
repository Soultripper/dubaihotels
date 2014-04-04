  

namespace :hotels do

  desc 'load Venere hotels'
  task :import_venere => :environment do
    Venere::Importer.hotels
  end


  def import_agoda_file(klass, filename)
    sql =  "copy #{klass.table_name} (#{klass.cols}) from '#{Rails.root}/tmp/agoda/#{filename}.csv' with (FORMAT csv, DELIMITER ',', HEADER true, QUOTE '}')"    
    Log.info sql
    ActiveRecord::Base.connection.execute sql
  end

end