class CountryCode < ActiveRecord::Base
  attr_accessible :iso2, :iso3, :iso_name, :name, :numcode

  def self.cached
    @@cached ||= CountryCode.all
  end
end
