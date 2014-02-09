class AgodaHotelFacility < ActiveRecord::Base
  attr_accessible :agoda_hotel_id, :group_description, :name, :property_id, :translated_name

  def self.import
    AgodaHotel.find_each do |hotel|
      xml = Agoda::Feeds.facilities ohotel_id: hotel.id
      xml.xpath('//facility').each {|xml_row| import_row xml_row}
    end
  end

  def self.import_row(xml)
    create!(
      agoda_hotel_id: value(xml, 'hotel_id'),
      group_description: value(xml, 'property_group_description'),
      name: value(xml, 'property_name'),
      property_id: value(xml, 'property_id'),
      translated_name: value(xml, 'property_translated_name')
    )
  end

  def self.value(xml, xpath)
    xml.at_xpath(xpath).text
  end
end
