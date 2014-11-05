class ResultsCounter

  attr_reader :counter, :providers

  def initialize
    @counter, @providers = {}, HotelsConfig.providers
    providers.each {|p| reset p}
  end

  def reset(provider)
    counter[provider] = {pages: 0, finished: false, errored: false}
  end

  def page_inc(provider)
    counter[provider][:pages] += 1
    Log.debug "#{provider} page #{page provider}"
  end

  def include?(provider)
    providers.include? provider
  end
  
  def page(provider)
    counter[provider][:pages]
  end

  def finish(provider)
    counter[provider][:finished] = true
  end


  def error(provider)
    finish provider
    counter[provider][:errored] = true
  end

  def finished?
    counter.all? {|c, p| p[:finished] || p[:errored]}
  end

end