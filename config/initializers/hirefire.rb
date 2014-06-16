HireFire::Resource.configure do |config|
  config.dyno(:worker) do
    Sidekiq::Workers.new.size
  end
end