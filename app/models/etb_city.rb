class EtbCity < ActiveRecord::Base
  attr_accessible :city_name, :city_rank, :country_id, :country_name, :latitude, :longitude, :province_id, :province_name, :url

  def self.cols
    "id, city_name, longitude, latitude,province_id, province_name, country_id, country_name, url, city_rank"
  end
end
