# config/initializers/soulmate.rb

Soulmate.redis = ENV["REDIS_URL"]
# or you can asign an existing instance of Redis, Redis::Namespace, etc.
# Soulmate.redis = $redis