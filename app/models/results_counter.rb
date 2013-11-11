class ResultsCounter

  attr_reader :counter, :providers

  def initialize(providers)
    @counter, @providers = {}, providers
    providers.each {|p| reset_provider p}
  end

  def reset_provider(provider)
    counter[provider] = {pages: 0, finished: false}
  end

  def inc(provider)
    counter[provider][:pages] += 1
  end

  def page(provider)
    counter[provider][:pages]
  end

  def finish(provider)
    counter[provider][:finished] = true
  end

  def finished?
    counter.all? {|c, p| p[:finished]}
  end

end