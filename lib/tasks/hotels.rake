namespace :hotels do



  desc 'Populate Expedia'
  task :compare => :environment do
    post_codes = EanHotel.limit(10).map {|hotel| hotel.postal_code.gsub('-','').gsub(' ','') if hotel.postal_code}.compact
  end

  
end