module HotelsConfig
  extend self

  attr_accessor :page_size, :max_page_size, :min_page_size

  @page_size  = 30
  @max_page_size  = 50
  @min_page_size = 1

  def setup(&block)
    yield self if block_given?
  end

end