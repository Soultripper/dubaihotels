require 'csv'    

namespace :admin do

  desc 'load Agoda files'
  task :load_agoda_hotels => :environment do
    import_agoda_file AgodaHotel, 'E342B777-64FD-4A49-9C9F-FEF4BA635863_EN'
  end


  def import_agoda_file(klass, filename)
    sql =  "copy #{klass.table_name} (#{klass.cols}) from '#{Rails.root}/tmp/agoda/#{filename}.csv' with (FORMAT csv, DELIMITER ',', HEADER true, QUOTE '}')"    
    Log.info sql
    ActiveRecord::Base.connection.execute sql
  end

end