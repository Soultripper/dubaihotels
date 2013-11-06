Rails.application.config.to_prepare do
  HotelsConfig.setup do |config|
    config.page_size  = 25
    config.max_page_size  = 50
    config.min_page_size = 1    
  end
end