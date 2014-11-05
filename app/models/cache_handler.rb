module CacheHandler
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  def persist
    Rails.cache.write(cache_key, self, expires_in: HotelsConfig.cache_expiry, race_condition_ttl: 60)
  end

  def find_or_create_from_cache
    Rails.cache.fetch cache_key do 
      Log.info "Creating new cache: #{cache_key}"
      self
    end   
  end

  module ClassMethods

    def from_cache(cache_key)
      Rails.cache.fetch cache_key if cache_key
    end


    def find_or_create_from_cache(cache_key)
      new(cache_key).find_or_create_from_cache   
    end

  end

end