class Analytics

  class << self 
    def publish(key, data)
      Keen.publish key, data
    end
  end

end