class Providers::Agoda::City < Providers::Base

  attr_accessible :id, :active_hotels, :agoda_country_id, :city_name, :city_translated, :latitude, :longitude, :no_area

  def self.import
    xml = Agoda::Feeds.cities
    xml.xpath('//city').each {|xml_row| import_row xml_row}
  end

  def self.import_row(xml)
    create!(id: value(xml, 'city_id'),
      agoda_country_id: value(xml, 'country_id'),
      city_name: value(xml, 'city_name'),
      city_translated: value(xml, 'city_translated'),
      active_hotels: value(xml, 'active_hotels'),
      longitude: value(xml, 'longitude'),
      latitude: value(xml, 'latitude'),
      no_area: value(xml, 'no_area')
    )
  end

  def self.value(xml, xpath)
    xml.at_xpath(xpath).text
  end  
end
