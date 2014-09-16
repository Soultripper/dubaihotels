require 'active_support/concern'

module MultiPluck
  extend ActiveSupport::Concern

  included do
    def self.pluck_all(relation, *args)
      connection.select_all(relation.select(args))
    end
  end
end

  