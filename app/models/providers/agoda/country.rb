class Providers::Agoda::Country < Providers::Base

  attr_accessible :id, :active_hotels, :agoda_continent_id,  :country_iso, :country_iso2, :country_name, :country_translated, :latitude, :longitude

  def self.import
    xml = Agoda::Feeds.countries
    xml.xpath('//country').each {|xml_row| import_row xml_row}
  end

  def self.import_row(xml)
    create!(id: value(xml, 'country_id'),
      agoda_continent_id: value(xml, 'continent_id'),
      country_name: value(xml, 'country_name'),
      country_translated: value(xml, 'country_translated'),
      active_hotels: value(xml, 'active_hotels'),
      country_iso: value(xml, 'country_iso'),
      country_iso2: value(xml, 'country_iso2'),
      longitude: value(xml, 'longitude'),
      latitude: value(xml, 'latitude')
    )
  end

  def self.value(xml, xpath)
    xml.at_xpath(xpath).text
  end
end
