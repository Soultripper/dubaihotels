class Providers::Agoda::Neighbourhood < Providers::Base
  attr_accessible :id, :active_hotels, :agoda_city_id, :area_name, :area_translated, :latitude, :longitude, :polygon

  def self.import
    xml = Agoda::Feeds.neighbourhoods
    xml.xpath('//area').each {|xml_row| import_row xml_row}
  end

  def self.import_row(xml)
    create!(id: value(xml, 'area_id'),
      agoda_city_id: value(xml, 'city_id'),
      area_name: value(xml, 'area_name'),
      area_translated: value(xml, 'area_translated'),
      active_hotels: value(xml, 'active_hotels'),
      longitude: value(xml, 'longitude'),
      latitude: value(xml, 'latitude'),
      polygon: value(xml, 'polygon')
    )
  end

  def self.value(xml, xpath)
    xml.at_xpath(xpath).text
  end

end
