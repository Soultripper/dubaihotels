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
end