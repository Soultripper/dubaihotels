  

namespace :hotels do

  desc 'load Venere hotels'
  task :import_venere => :environment do
    Venere::Importer.hotels
  end

end