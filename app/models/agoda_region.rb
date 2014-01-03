class AgodaRegion < ActiveRecord::Base
  attr_accessible :name, :name_translated

  def self.import
    xml = Agoda::Feeds.regions
    xml.xpath('//state').each {|xml_row| import_row xml_row}
  end

  def self.import_row(xml)
    create!(id: value(xml, 'state_id'),
      name: value(xml, 'state_name'),
      name_translated: value(xml, 'state_translated')
    )
  end

  def self.value(xml, xpath)
    xml.at_xpath(xpath).text
  end  
end
