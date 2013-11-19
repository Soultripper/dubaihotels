class PushNotifier


  CHANNEL_PREFIX = 'hot5'
  EVENT = :notification

  def channel
    @channel = "hot5.com"
  end

  def push(results)
    Thread.new do
      Pusher[channel].trigger('results_update', { results: results})
      ActiveRecord::Base.connection.close
    end
  end


end