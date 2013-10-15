Rails.application.config.to_prepare do
  Booking::Config.setup do |config|
    config.username = 'broadbasev'
    config.password = '5790'
  end
end