module HotelsConfig
  class << self

    attr_accessor :page_size, :max_page_size, :min_page_size, :max_price

    def setup
      yield self
    end
  end
end