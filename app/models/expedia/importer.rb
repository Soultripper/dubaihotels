class Expedia::Importer

  class << self 
    def import
      EanHotel.joins('left join hotels on hotels.id = ean_hotels.id and hotels.id is null').each do |hotel|
        process_exact_origin hotel
      end
     # post_codes = EanHotel.limit(10).map {|hotel| hotel.postal_code.gsub('-','').gsub(' ','') if hotel.postal_code}.compact
    end

    def process_exact_origin(ean_hotel)
      matching_hotels = Hotel.within(0.01, origin: ean_hotel)

      if matching_hotels.empty?
        Log.info "[FAIL] Exact Origin Match #{ean_hotel.id}: No match"
        return
      end

      if matching_hotels.length > 1
        Log.info "[FAIL] Exact Origin Match #{ean_hotel.id}: #{matching_hotels.length} matches"
        return
      end

      hotel = matching_hotels[0]  
      hotel.update_attribute :ean_hotel_id, ean_hotel.id
      Log.info "[SUCCESS[ Exact Origin Match #{ean_hotel.id}: Name[#{hotel.name}, #{ean_hotel.name}], City:[#{hotel.city}, #{ean_hotel.city}]. EAN hotel id updated"
    end
  end

end