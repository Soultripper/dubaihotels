require 'parser'
class Agoda::HotelFacility

  def self.import(file)
    # last_imported = AdminConfig.instance.netflix_last_import || 100.years.ago
     Xml::Parser.new(Nokogiri::XML::Reader(open(file))) do
     
      for_element 'facility' do
        hotel_facility = AgodaHotelFacility.new

        inside_element  do
          for_element('hotel_id')                   {hotel_facility.agoda_hotel_id = inner_xml.to_i}
          for_element('property_group_description') {hotel_facility.group_description = inner_xml}
          for_element('property_id')                {hotel_facility.property_id = inner_xml.to_i}
          for_element('property_name')              {hotel_facility.name = inner_xml}
          for_element('property_translated_name')   {hotel_facility.translated_name = inner_xml}
        end

        hotel_facility.save
      end
    end

  end

end