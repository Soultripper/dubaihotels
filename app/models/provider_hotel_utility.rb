class ProviderHotelUtility

  def self.hotel_dto(provider_hotel, search_criteria, options={})
    return nil unless provider_hotel.provider_id


    if provider_hotel.respond_to? :rooms_available?
      return unless provider_hotel.send :rooms_available?
    end

    {
      provider: provider_hotel.provider,
      provider_id: provider_hotel.provider_id,
      min_price: provider_hotel.avg_min_price(search_criteria),
      max_price: provider_hotel.avg_max_price(search_criteria),
      room_count: provider_hotel.rooms_count,
      rooms: rooms_dto(provider_hotel.rooms, search_criteria) 

    }
  # rescue => msg  
  #   Log.error "#{provider_hotel.provider} Hotel #{provider_hotel.provider_id} failed to convert: #{msg}"
  #   nil
  end


  def self.rooms_dto(rooms, search_criteria)
    rooms.map{|r| r.commonize(search_criteria)}
  end

end
