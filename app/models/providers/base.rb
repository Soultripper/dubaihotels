class Providers::Base < ActiveRecord::Base

  self.abstract_class = true

  def self.table_name
    names = name.split('::')[1..2].join('_').snakecase.pluralize
    "providers.#{names}"
  end
end
