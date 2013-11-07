class HotelAmenity < ActiveRecord::Base
  attr_accessible :id, :name, :value, :flag

  def self.all
    @@amenities ||= super
  end

  def self.filter(selection)
    all.select {|amenity| selection.include? amenity[:value]}
  end

  def self.mask(selection)
    filter(selection).map(&:flag).sum
  end
end
