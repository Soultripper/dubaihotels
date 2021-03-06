Rails.application.config.to_prepare do
  Rails.cache.silence!
  HotelsConfig.setup do |config|
    config.page_size  = 15
    config.max_page_size  = 50
    config.min_page_size = 1    
    config.min_price = 25
    config.max_price = 1000
    config.cache_expiry = 20.minutes

    if Rails.env == "production"
      config.providers = [:booking, :agoda, :expedia, :easy_to_book, :splendia, :laterooms, :venere]
    else
      config.providers = [:booking, :agoda, :expedia, :easy_to_book,  :laterooms, :venere, :splendia]
    end
  end

  Geocoder.configure(cache: Redis.new(url: ENV["REDISCLOUD_URL"]))
end