class EtbCity < ActiveRecord::Base
  attr_accessible :city_name, :city_rank, :country_id, :country_name, :latitude, :longitude, :province_id, :province_name, :url
end
