module Booking::Config
  class << self

    attr_accessor :username, :password

    def setup
      yield self 
    end

    def url
    end
  end
end