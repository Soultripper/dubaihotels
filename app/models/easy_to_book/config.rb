require 'uri'

module EasyToBook
  class Config

    attr_accessor :env, :endpoint, :username, :password, :campaignid

    DEFAULTS = {
      :test => {
        :endpoint => 'http://testnl.etbxml.com/api',
        :username => 'affiliate',
        :password => 'affiliate',
        :campaignid => '1'
      },
      :production => {
        :endpoint => 'http://www.etbxml.com/api',
        :username => 'hot5hotels',
        :password => '21efef97',
        :campaignid => '280828275'
      }
    }.freeze

    def initialize
      self.env = :production
    end

    def env=(value)
      if (@env = value) == :production
        @endpoint = DEFAULTS[:production][:endpoint]
        @username ||= DEFAULTS[:production][:username]
        @password ||= DEFAULTS[:production][:password]
        @campaignid ||= DEFAULTS[:production][:campaignid]
      else
        @endpoint = DEFAULTS[:test][:endpoint]
        @username ||= DEFAULTS[:test][:username]
        @password ||= DEFAULTS[:test][:password]
        @campaignid ||= DEFAULTS[:test][:campaignid]
      end
    end

    def uri
      URI.parse(endpoint)
    end

    class << self
      def config
        @@etb_config ||= EasyToBook::Config.new
      end

      def setup(&block)
        block.call(config) if block_given?
      end
    end
  end
end
